class HtmlPage
  attr_accessor :route

  def initialize(route)
    self.route = route
  end

  def url
    @url ||= route.gsub /^tgr/, 'http://tomsk.gov.ru'
  end

  def site
    @site ||= 'tomsk.gov.ru'
  end

  def text
    @text ||= Sanitize.clean(html)
  end

  def title
    @title ||= nokogiri.css('html head title').first.try(:content)
  end

  protected
    def real_url
      @real_url ||= route.gsub /^tgr/, 'http://nocache-tgr.esp.tomsk.gov.ru'
    end

    def html
      @html ||= Requester.new(real_url).response_body
    end

    def nokogiri
      @nokogiri ||= Nokogiri::HTML(html)
    end
end
