class CmsSubscriber
  attr_accessor :logger

  def add(url)
    if page = Page.find_by_url(url)
      page.update_html
    else
      Page.new(:url => url).update_html
    end
  end

  def remove(url)
    Page.where("url LIKE '#{url}%'").destroy_all
  end
end
