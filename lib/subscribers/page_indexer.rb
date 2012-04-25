class PageIndexer
  def queue
    'esp.queue'
  end

  def routing_key
    'searcher.*'
  end

  def run(routing_key, body)
    Page.update_index(header.routing_key, body)
  end
end
