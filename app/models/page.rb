class Page < ActiveRecord::Base
  attr_accessible :route, :url, :title, :text

  attr_accessor :site, :url_for_index

  searchable do
    string :site
    text :title
    text :text
    boost :boost
  end

  def reindex
    self.site = html.site
    self.url = html.url
    self.title = html.title
    self.text = html.text
    save!
  end

  def boost
    @boost ||= 1 - route.count('/') * 0.01
  end

  def html
    @html ||= HtmlPage.new(route)
  end
end
