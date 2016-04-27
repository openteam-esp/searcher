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
    string  :url,  :stored => true

    boolean :has_html

    integer :level

    text :title,                      :boost => 1.1
    text :title_ru, :stored => true,  :boost => 1.05

    text :text,                       :boost => 1
    text :text_ru,  :stored => true,  :boost => 0.9

    time :entry_date, :trie => true
  end

  def html_page
    @html_page ||= HtmlPage.new(html) if html?
  end

  def update_html
    update_attributes! :html => page_io.read
    self
  end

  def self.search_by(params)
    Page.search do |search|
      if params[:q].to_s =~ /[[:alnum:]]/
        search.keywords params[:q] do
          highlight :title_ru,  :max_snippets => 2, :merge_contiguous_fragments => true
          highlight :text_ru,   :max_snippets => 3, :merge_contiguous_fragments => true
        end
        search.with(:has_html, true)
        search.with(:url).starting_with(params[:url]) if (params[:url])
        search.paginate(:page => (params[:page] || 1).to_i, :per_page => params[:per_page])
        Boostificator.new(:search => search, :field => :entry_date_dt, :extra_boost => "pow(0.9,level_i)").adjust_solr_params do |solr_params|
          solr_params[:'hl.fl'].each do |field|
            solr_params[:"f.#{field}.hl.alternateField"] = field
            solr_params[:"f.#{field}.hl.maxAlternateFieldLength"] =
              (solr_params[:"f.#{field}.hl.snippets"] || 1).to_i * (solr_params[:"f.#{field}.hl.fragsize"] || 100).to_i
          end
          solr_params[:'hl.maxAlternateFieldLength']
        end
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
      self.level += 3 if entry_date.present?
    end
end
