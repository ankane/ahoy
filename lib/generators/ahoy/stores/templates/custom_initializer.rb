class CustomStore

  def track_event(name, properties, options)
  end

  def track_visit(ahoy)
  end

  def current_visit(ahoy)
  end

end

Ahoy.store = CustomStore.new
