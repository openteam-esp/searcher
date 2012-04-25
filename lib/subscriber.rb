require 'amqp'

class Subscriber
  def initialize
    logger.info "Running subscriber"
  end

  def run
    AMQP.start do |connection|
      channel = AMQP::Channel.new(connection)
      exchange = channel.topic('esp.exchange')
      queue = channel.queue('esp.queue', :durable => true)

      queue.bind(exchange, :routing_key => 'searcher.*')

      Signal.trap("TERM") do
        connection.close do
          logger.info "Stopping subscriber"
          EM.stop { exit }
        end
      end

      channel.prefetch(1)
      queue.subscribe(:ack => true) do |header, body|
        logger.debug("Receive #{header.routing_key}: #{body}")
        Page.update_index(header.routing_key, body)
        header.ack
      end
    end
  end

  def logger
    @@logger ||= ActiveSupport::BufferedLogger.new("#{Rails.root}/log/subscriber.log")
  end
end
