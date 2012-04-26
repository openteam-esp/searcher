class PageIndexer
  def queue
    'esp.queue'
  end

  def routing_key
    'searcher.*'
  end

  def run(action, url)
    case action
    when 'searcher.add'
      Page.index_url(url)
    when 'searcher.remove'
      Page.destroy_url(url)
    end
  end
end
