class Ahoy::Store < Ahoy::Stores::BunnyStore
  def visits_queue
    "ahoy_visits"
  end

  def events_queue
    "ahoy_events"
  end
end
