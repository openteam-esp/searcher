class HtmlPage
  attr_accessor :url

  def initialize(url)
    self.url = url
  end

  def text
    @text ||= body.to_s.gsub(/[[:space:]]+/, ' ').strip
  end

  def title
    @title ||= nokogiri.css('html head title').map(&:content).join(' ').to_s.strip
  end

  protected
    def real_url
      @real_url ||= url.gsub(%r{^http://}, 'http://nocache-')
    end

    def body
      @body ||= nokogiri.css('.index').map(&:content).map{|content| Sanitize.clean(content)}.join(' ')
    end

    def html
      @html ||=  Requester.new(real_url).response_body
    end

    def nokogiri
      @nokogiri ||= Nokogiri::HTML(html).tap do | nokogiri |
        nokogiri.css('.noindex').map(&:remove)
      end
    end
end
