class Ahoy::Store < Ahoy::Stores::NsqStore
  def visits_topic
    "ahoy_visits"
  end

  def events_topic
    "ahoy_events"
  end
end
