class Ahoy::Store < Ahoy::Stores::KafkaStore
  def visits_topic
    "ahoy_visits"
  end

  def events_topic
    "ahoy_events"
  end
end
