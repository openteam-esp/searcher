class CmsSubscriber
  attr_accessor :logger

  def add(url)
    page = Page.find_or_create_by_url(url)
    page.update_html
  end

  def remove(url)
    Page.where("url LIKE '#{url}%'").find_each do |page|
      page.destroy
    end
  end
end
