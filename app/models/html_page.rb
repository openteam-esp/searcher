class HtmlPage
  attr_accessor :html

  def initialize(html)
    self.html = html
  end

  def text
    @text ||= text_by_css('.index')
  end

  def title
    @title ||= text_by_css('html head title').split('|').first.to_s.strip
  end

  def entry_date
    @entry_date ||= nokogiri.css('html head meta[name=entry_date]').first.try(:[], :content).try(:to_datetime)
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
