require 'open-uri'

class Page < ActiveRecord::Base
  attr_accessible :url, :html

  validates :url, :presence => true, :uniqueness => true

  delegate :title, :text, :entry_date, :to => :html_page, :allow_nil => true

  alias_method :title_ru, :title
  alias_method :text_ru, :text

  alias_attribute :has_html, :html?

  before_save :set_level

  searchable do
    string  :url, :stored => true

    boolean :has_html

    integer :level

    text :title, :stored => true,  :boost => 1.1
    text :title_ru, :stored => true,  :boost => 1.05

    text :text, :stored => true,  :boost => 1
    text :text_ru, :stored => true,  :boost => 0.9

    time :entry_date, :trie => true
  end

  def html_page
    @html_page ||= HtmlPage.new(url, html) if html?
  end

  def update_html
    update_attributes! :html => page_io.read
    self
  end

  def self.search_by(params)
    Page.search do |search|
      if params[:q].present?
        search.keywords params[:q], :highlight => true
        search.with(:has_html, true)
        search.with(:url).starting_with(params[:url]) if (params[:url])
        search.paginate(:page => (params[:page] || 1).to_i, :per_page => params[:per_page])
        Boostificator.new(:search => search, :field => :entry_date_dt, :extra_boost => "pow(0.9,level_i)").adjust_solr_params
      else
        # TODO: change this for appropriate solr method
        search.with(:url, 'nonexistent-url')
      end
    end
  end


  private
    def page_io
      open(noncached_url)
    rescue SocketError => e
      if e.message == 'getaddrinfo: Name or service not known'
        open(url)
      else
        raise e
      end
    end

    def noncached_url
      @noncached_url ||= url.gsub(%r{^http://}, 'http://nocache.')
    end

    def set_level
      self.level = [url.count('/'), 3].max - 3
    end
end
