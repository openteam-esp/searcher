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

  def self.update_index(action, url)
    case action
    when 'searcher.add'
      index_url(url)
    when 'searcher.remove'
      destroy_url(url)
    end
  end

  def self.index_url(url)
    if page = find_by_url(url)
      page.index
    else
      create(:url => url)
    end
  end

  def self.destroy_url(url)
    Page.where("url like '#{url}%'").destroy_all
  end

  def self.search_by(params)
    Page.search {
      keywords params[:q], :highlight => true
      with(:url).starting_with(params[:url])
      paginate(:page => params[:page].to_i, :per_page => params[:per_page])
    }
  end
end
