class Page < ActiveRecord::Base
  attr_accessible :url, :html

  validates :url, :presence => true, :uniqueness => true

  delegate :title, :text, :entry_date, :to => :html_page, :allow_nil => true

  alias_method :title_ru, :title
  alias_method :text_ru, :text

  alias_attribute :has_html, :html?

  searchable do
    string  :url, :stored => true

    boolean :has_html

    text :title, :stored => true,  :boost => 2
    text :title_ru, :stored => true,  :boost => 1.8

    text :text, :stored => true,  :boost => 1
    text :text_ru, :stored => true,  :boost => 0.9

    time :entry_date, :trie => true

    boost :boost
  end

  def boost
    @boost ||= 0.9 ** url.count('/')
  end

  def html_page
    @html_page ||= HtmlPage.new(url, html) if html?
  end

  def update_html
    requester = Requester.new(real_url)
    if requester.response_status == 200
      update_attributes! :html => requester.response_body
      self
    else
      throw "Cann't index #{url}. HTTP response code is #{requester.response_status}"
    end
  end

  def self.search_by(params)
    Page.search do |search|
      search.keywords params[:q], :highlight => true
      search.with(:has_html, true)
      search.with(:url).starting_with(params[:url]) if (params[:url])
      search.paginate(:page => (params[:page] || 1).to_i, :per_page => params[:per_page])
      Boostificator.new(:search => search, :field => :entry_date_dt).adjust_solr_params
    end
  end


  private
    def real_url
      @real_url ||= url.gsub(%r{^http://}, 'http://nocache.')
    end
end
