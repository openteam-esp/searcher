class HtmlPage
  attr_accessor :url, :html

  def initialize(url, html)
    self.url = url
    self.html = html
  end

  def text
    @text ||= body.to_s.gsub(/[[:space:]]+/, ' ').strip
  end

  def title
    @title ||= nokogiri.css('html head title').first.try(:content).to_s.split('|').first.squish
  end

  protected
    def body
      @body ||= nokogiri.css('.index').map(&:content).map{|content| Sanitize.clean(content)}.join(' ')
    end

    def nokogiri
      @nokogiri ||= Nokogiri::HTML(html).tap do | nokogiri |
        nokogiri.css('.noindex').map(&:remove)
      end
    end
end
