class Ahoy::Store < Ahoy::Stores::NatsStore
  def visits_subject
    "ahoy_visits"
  end

  def events_subject
    "ahoy_events"
  end
end
