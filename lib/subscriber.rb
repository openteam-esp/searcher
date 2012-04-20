require 'amqp'

class Subscriber
  READ_QUEUE = 'esp.searcher.index'

  def self.subscribe
    AMQP.start do |connection|
      channel = AMQP::Channel.new(connection)
      queue   = channel.queue(READ_QUEUE, :durable => true)

      Signal.trap("INT") do
        connection.close do
          EM.stop { exit }
        end
      end

      channel.prefetch(1)
      queue.subscribe(:ack => true) do |header, body|
        Page.index_url(body)
        header.ack
      end
    end
  end
end
