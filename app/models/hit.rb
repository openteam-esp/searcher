class Hit
  attr_accessor :title, :excerpt, :route
  def initialize(sunspot_hit)
    self.title = self.highlight(sunspot_hit, :title, 255)
    self.excerpt = self.highlight(sunspot_hit, :text, 1024)
    self.route = sunspot_hit.stored(:route)
  end

  def as_json(options)
    {title: title, excerpt: excerpt, route: route}.as_json(options)
  end

  protected
    def highlight(hit, field, length)
      highlights = hit.highlights(field)
      if highlights.any?
        highlights.reduce([]) do |result, highlight|
          result << highlight.format { |word| "<em>#{word}</em>" } if result.length < length
          result
        end.join('... ')
      else
        hit.stored(field).first.truncate(length, :separator => ' ')
      end
    end
end
