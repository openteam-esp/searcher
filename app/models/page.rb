class Page < ActiveRecord::Base
  attr_accessible :content, :title, :url

  searchable do
    string :site
    text :url,      :boost => 3
    text :title,    :boost => 2
    text :content
  end

  def site
    URI.parse(url).host
  end
end
