class Hit
  attr_accessor :title, :excerpt, :url

  def initialize(sunspot_hit)
    self.title = self.highlight(sunspot_hit, :title, 255)
    self.excerpt = self.highlight(sunspot_hit, :text, 512)
    self.url = sunspot_hit.stored(:url)
  end

  def as_json(options)
    {title: title, excerpt: excerpt, url: url}.as_json(options)
  end

  protected
    def highlight(hit, field, length)
      highlight = nil;
      [nil, 'ru'].each do | lang |
        highlights = hit.highlights([field, lang].join('_'))
        if highlights.any?
          highlight = highlights.reduce([]) do |result, highlight|
            result << highlight.format { |word| "<em>#{word}</em>" } if result.length < length
            result
          end.join('... ')
          break
        end
      end
      highlight || hit.stored(field).first.truncate(length, :separator => ' ')
    end
end
