class Page < ActiveRecord::Base
  attr_accessible :route, :url, :title, :text

  attr_accessor :site, :url_for_index

  searchable do
    string :site
    text :url,    :stored => true, :boost => 2
    text :title,  :stored => true, :boost => 1.5
    text :text,   :stored => true
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

  def self.highlighted_hits(params)
    find_pages(params).hits.map { |hit|
      Page.new do |page|
        page.title = self.highlight(hit, :title, 255)
        page.text = self.highlight(hit, :text, 1024)
        page.url = hit.stored(:url).first
      end
    }
  end

  def self.highlight(hit, field, max_length)
    if highlight = hit.highlight(field)
      highlight.format { |word| "<em>#{word}</em>" }
    else
      hit.stored(field).first.truncate(max_length, :separator => ' ')
    end
  end

  def self.find_pages(params)
    Page.search {
      keywords params[:q], :highlight => true
      with(:site, params[:site]) if params[:site]
    }
  end
end
