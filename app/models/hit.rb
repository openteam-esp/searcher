# encoding: utf-8

class Hit
  attr_accessor :sunspot_hit

  def initialize(sunspot_hit)
    self.sunspot_hit = sunspot_hit
  end

  def title
    @title ||= highlight(:title_ru)
  end

  def excerpt
    @excerpt ||= highlight( :text_ru)
  end

  def url
    @url ||= sunspot_hit.stored(:url)
  end

  def score
    @score ||= sunspot_hit.score
  end

  def attributes
    %w[title excerpt url score]
  end

  def as_json(params)
    attributes.inject({}) {|j,a| j[a] = self.send(a); j}
  end

  private

  def highlight(field)
    sunspot_hit.highlights(field).map(&:formatted).join(' … ')
  end
end
