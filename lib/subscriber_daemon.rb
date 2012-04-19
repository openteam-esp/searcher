require 'simple-daemon'
require 'amqp'

class SubscriberDaemon < SimpleDaemon::Base
  #SimpleDaemon::WORKING_DIRECTORY = "#{BOX.log_dir}"
  READ_QUEUE = 'esp.cms.updated.page'

  #def self.start
    #puts "STARTING #{classname} #{Time.now}"
    #STDOUT.flush
    #EM.run do
      #subscribe_to_read_queue
    #end
  #end

  #def self.stop
    #puts "STOPPING #{classname} #{Time.now}"
    #STDOUT.flush
  #end

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
        Page.find_or_create_by_route(body).reindex
        header.ack
      end
    end
  end
end
