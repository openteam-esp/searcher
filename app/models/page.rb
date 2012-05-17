class Page < ActiveRecord::Base
  attr_accessible :url, :html

  validates_presence_of :url

  delegate :title, :text, :to => :html_page

  searchable do
    string  :url, :stored => true
    text    :url, :boost => 2 do url.gsub(/[^[:alnum:]]+/, ' ') end
    {title: 2, text: 1}.each do |field, boost|
      text    field, :stored => true,  :boost => boost
      text    "#{field}_ru", :stored => true,  :boost => boost * 0.9 do
        self.send field
      end
    end
    boost   :boost
  end

  def boost
    @boost ||= 1 - url.count('/') * 0.01
  end

  def html_page
    @html_page ||= begin
                     update_html unless html?
                     HtmlPage.new(url, html)
                   end
  end

  def update_html
    requester = Requester.new(real_url)
    if requester.response_status == 200
      update_attributes! :html => requester.response_body
    else
      throw "Cann't index #{url}. HTTP response code is #{requester.response_status}"
    end
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
