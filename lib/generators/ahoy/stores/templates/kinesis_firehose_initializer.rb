class Ahoy::Store < Ahoy::Stores::KinesisFirehoseStore
  def credentials
    {
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      region: "us-east-1"
    }
  end

  def visits_stream
    "ahoy_visits"
  end

  def events_stream
    "ahoy_events"
  end
end
