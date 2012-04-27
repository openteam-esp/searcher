class CmsSubscriber
  def add(url)
    if page = Page.find_by_url(url)
      page.index
    else
      Page.create(:url => url)
    end
  end

  def remove(url)
    Page.where("url LIKE '#{url}%'").destroy_all
  end
end
