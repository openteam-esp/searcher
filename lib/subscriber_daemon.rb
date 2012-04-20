require 'simple-daemon'
require 'amqp'

class SubscriberDaemon < SimpleDaemon::Base
  READ_QUEUE = 'esp.searcher.not_indexed_routes'

  def self.subscribe_to_read_queue
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
        Page.index_route(body)
        header.ack
      end
    end
  end
end
