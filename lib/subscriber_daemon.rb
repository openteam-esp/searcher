class SubscriberDaemon

  def initialize
    SubscriberDaemon.info 'Running subscriber'
  end

  def run
    Subscriber.subscribe
  end

  class << self
    def logger
      @logger ||= ActiveSupport::BufferedLogger.new("#{Rails.root}/log/subscriber.log")
    end

    delegate :debug, :info, :warn, :to => :logger
  end
end
