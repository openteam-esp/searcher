class HtmlPage
  attr_accessor :url, :html

  def initialize(url, html)
    self.url = url
    self.html = html
  end

  def text
    @text ||= text_by_css('.index')
  end

  def title
    @title ||= text_by_css('html head title').split('|').first.to_s.strip
  end

  protected
    def text_by_css(selector)
      if (nodes = nokogiri.css(selector))
        nodes.map(&:content).map{|content| Sanitize.clean(content)}.join(' ').to_s.gsub(/[[:space:]]+/, ' ').strip
      else
        ''
      end
    end

    def nokogiri
      @nokogiri ||= Nokogiri::HTML(html.gsub(/</, ' <')).tap do | nokogiri |
        nokogiri.css('.noindex').map(&:remove)
      end
    end
end
