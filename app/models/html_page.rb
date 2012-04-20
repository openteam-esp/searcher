class HtmlPage
  attr_accessor :route

  def initialize(route)
    self.route = route
  end

  def text
    @text ||= Sanitize.clean(html).to_s.gsub(/[[:space:]]+/, ' ').strip
  end

  def title
    @title ||= nokogiri.css('html head title').map(&:content).join(' ').to_s.strip
  end

  protected
    def real_url
      @real_url ||= route.gsub(/^tgr/, 'http://nocache-tgr.esp.tomsk.gov.ru')
    end

    def html
      @html ||= Requester.new(real_url).response_body
    end

    def nokogiri
      @nokogiri ||= Nokogiri::HTML(html)
    end
end
