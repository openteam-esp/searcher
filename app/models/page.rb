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
    @boost ||= begin
                 boost = [1 - url.count('/') * 0.1, 0.1].max
                 boost += 45 unless entry_date
               end
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
    Page.search {
      keywords params[:q], :highlight => true
      with(:has_html, true)
      with(:url).starting_with(params[:url]) if (params[:url])
      paginate(:page => (params[:page] || 1).to_i, :per_page => params[:per_page])
      adjust_solr_params do |params|
        params[:q] = "{!boost b=recip(ms(NOW,entry_date_dt),3.16e-11,1,1) defType=dismax}#{params[:q]}"
      end
    }
  end

  private
    def real_url
      @real_url ||= url.gsub(%r{^http://}, 'http://nocache.')
    end
end
