require 'amqp'

class Subscriber
  READ_QUEUE = 'esp.searcher.index'

  def self.subscribe
    AMQP.start do |connection|
      channel = AMQP::Channel.new(connection)
      exchange = channel.topic('esp')
      queue = channel.queue('', :durable => true)

      queue.bind(exchange, :routing_key => 'searcher.*')

      Signal.trap("INT") do
        connection.close do
          EM.stop { exit }
        end
      end

      channel.prefetch(1)
      queue.subscribe(:ack => true) do |header, body|
        Page.update_index(header.routing_key, body)
        header.ack
      end
    end
  end
end
