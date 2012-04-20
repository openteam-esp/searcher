class Page < ActiveRecord::Base
  attr_accessible :route

  attr_accessor :site, :url_for_index

  delegate :title, :text, :to => :html

  searchable do
    string  :route, :stored => true
    text    :route, :boost => 2 do p route.split('/')[1..-1].join(' ').gsub(/[_-]+/, ' ') end
    text    :title, :stored => true,  :boost => 1.5
    text    :text,  :stored => true
    boost   :boost
  end

  def boost
    @boost ||= 1 - route.count('/') * 0.01
  end

  def html
    @html ||= HtmlPage.new(route)
  end

  def self.index_route(route)
    find_by_route(route).try(&:index) || create(:route => route)
  end

  def self.hits(query, site)
    find_pages(query, site).hits.map { |hit| Hit.new(hit) }
  end

  def self.find_pages(query, route)
    Page.search {
      keywords query, :highlight => true
      with(:route).starting_with(route) if route
    }
  end
end
