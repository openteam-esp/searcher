class Page < ActiveRecord::Base
  attr_accessible :url

  delegate :title, :text, :to => :html

  searchable do
    string  :url, :stored => true
    text    :url, :boost => 2 do url.gsub(/[^[:alnum:]]+/, ' ') end
    text    :title, :stored => true,  :boost => 1.5
    text    :text,  :stored => true
    boost   :boost
  end

  def boost
    @boost ||= 1 - url.count('/') * 0.01
  end

  def html
    @html ||= HtmlPage.new(url)
  end

  def self.index_url(url)
    find_by_url(url).try(&:index) || create(:url => url)
  end

  def self.find_pages(query, url)
    Page.search {
      keywords query, :highlight => true
      with(:url).starting_with(url) if url
    }
  end
end
