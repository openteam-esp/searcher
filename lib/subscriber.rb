require 'amqp'

class Subscriber
  def start
    workers.each do |worker|
      AMQP.start(Settings['amqp.url']) do |connection|
        channel = AMQP::Channel.new(connection)
        channel.prefetch(1)

        exchange = channel.topic('esp.exchange')
        queue = channel.queue(worker.queue, :durable => true)

        queue.bind(exchange, :routing_key => worker.routing_key)

        Signal.trap("TERM") do
          connection.close do
            logger.info "#{worker.class} stopped"
            EM.stop { exit }
          end
        end

        queue.subscribe(:ack => true) do |header, body|
          logger.debug("#{worker.class} receive #{header.routing_key}: #{body}")
          worker.run(header.routing_key)
          header.ack
        end

        logger.info "#{worker.class} started"
      end
    end
  end

  def workers
    Dir.glob("#{Rails.root}/lib/subscribers/*").map do |worker_path|
      require worker_path
      File.basename(worker_path, '.rb').classify.constantize.new
    end
  end

  def logger
    @@logger ||= ActiveSupport::BufferedLogger.new("#{Rails.root}/log/subscriber.log")
  end
end
