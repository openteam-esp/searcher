class Page < ActiveRecord::Base
  attr_accessible :url, :html

  delegate :title, :text, :to => :html_page

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

  def html_page
    @html_page ||= HtmlPage.new(url, html)
  end

  def update_html
    update_attributes! :html => Requester.new(real_url).response_body
  end

  def self.search_by(params)
    Page.search {
      keywords params[:q], :highlight => true
      with(:url).starting_with(params[:url]) if (params[:url])
      paginate(:page => (params[:page] || 1).to_i, :per_page => params[:per_page])
    }
  end

  private
    def real_url
      @real_url ||= url.gsub(%r{^http://}, 'http://nocache-')
    end
end
