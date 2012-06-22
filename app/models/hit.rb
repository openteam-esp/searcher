class Hit
  attr_accessor :title, :excerpt, :url, :score

  def initialize(sunspot_hit)
    self.title = self.highlight(sunspot_hit, :title, 255)
    self.excerpt = self.highlight(sunspot_hit, :text, 512)
    self.url = sunspot_hit.stored(:url)
    self.score = sunspot_hit.score
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
      highlight || hit.result.send(field).truncate(length, :separator => ' ')
    end
end
