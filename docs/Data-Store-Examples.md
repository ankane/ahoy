# Data Store Examples

- [Kafka](#kafka)
- [RabbitMQ](#rabbitmq)
- [Fluentd](#fluentd)
- [NATS](#nats)
- [NSQ](#nsq)
- [Amazon Kinesis Firehose](#amazon-kinesis-firehose)

### Kafka

Add [ruby-kafka](https://github.com/zendesk/ruby-kafka) to your Gemfile.

```ruby
class Ahoy::Store < Ahoy::BaseStore
  def track_visit(data)
    post("ahoy_visits", data)
  end

  def track_event(data)
    post("ahoy_events", data)
  end

  def geocode(data)
    post("ahoy_geocode", data)
  end

  def authenticate(data)
    post("ahoy_auth", data)
  end

  private

  def post(topic, data)
    producer.produce(data.to_json, topic: topic)
  end

  def producer
    @producer ||= begin
      client =
        Kafka.new(
          seed_brokers: ENV["KAFKA_URL"] || "localhost:9092",
          logger: Rails.logger
        )
      producer = client.async_producer(delivery_interval: 3)
      at_exit { producer.shutdown }
      producer
    end
  end
end
```

### RabbitMQ

Add [bunny](https://github.com/ruby-amqp/bunny) to your Gemfile.

```ruby
class Ahoy::Store < Ahoy::BaseStore
  def track_visit(data)
    post("ahoy_visits", data)
  end

  def track_event(data)
    post("ahoy_events", data)
  end

  def geocode(data)
    post("ahoy_geocode", data)
  end

  def authenticate(data)
    post("ahoy_auth", data)
  end

  private

  def post(topic, message)
    channel.queue(topic, durable: true).publish(message.to_json)
  end

  def channel
    @channel ||= begin
      conn = Bunny.new
      conn.start
      conn.create_channel
    end
  end
end
```

### Fluentd

Add [fluent-logger](https://github.com/fluent/fluent-logger-ruby) to your Gemfile.

```ruby
class Ahoy::Store < Ahoy::BaseStore
  def track_visit(data)
    post("ahoy_visits", data)
  end

  def track_event(data)
    post("ahoy_events", data)
  end

  def geocode(data)
    post("ahoy_geocode", data)
  end

  def authenticate(data)
    post("ahoy_auth", data)
  end

  private

  def post(topic, message)
    logger.post(topic, message)
  end

  def logger
    @logger ||= Fluent::Logger::FluentLogger.new("ahoy", host: "localhost", port: 24224)
  end
end
```

### NATS

Add [nats-pure](https://github.com/nats-io/pure-ruby-nats) to your Gemfile.

```ruby
class Ahoy::Store < Ahoy::BaseStore
  def track_visit(data)
    post("ahoy_visits", data)
  end

  def track_event(data)
    post("ahoy_events", data)
  end

  def geocode(data)
    post("ahoy_geocode", data)
  end

  def authenticate(data)
    post("ahoy_auth", data)
  end

  private

  def post(topic, data)
    client.publish(topic, data.to_json)
  end

  def client
    @client ||= begin
      require "nats/io/client"
      client = NATS::IO::Client.new
      client.connect(servers: (ENV["NATS_URL"] || "nats://127.0.0.1:4222").split(","))
      client
    end
  end
end
```

### NSQ

Add [nsq-ruby](https://github.com/wistia/nsq-ruby) to your Gemfile.

```ruby
class Ahoy::Store < Ahoy::BaseStore
  def track_visit(data)
    post("ahoy_visits", data)
  end

  def track_event(data)
    post("ahoy_events", data)
  end

  def geocode(data)
    post("ahoy_geocode", data)
  end

  def authenticate(data)
    post("ahoy_auth", data)
  end

  private

  def post(topic, data)
    client.write_to_topic(topic, data.to_json)
  end

  def client
    @client ||= begin
      require "nsq"
      client = Nsq::Producer.new(
        nsqd: ENV["NSQ_URL"] || "127.0.0.1:4150"
      )
      at_exit { client.terminate }
      client
    end
  end
end
```

### Amazon Kinesis Firehose

Add [aws-sdk-firehose](https://github.com/aws/aws-sdk-ruby) to your Gemfile.

```ruby
class Ahoy::Store < Ahoy::BaseStore
  def track_visit(data)
    post("ahoy_visits", data)
  end

  def track_event(data)
    post("ahoy_events", data)
  end

  def geocode(data)
    post("ahoy_geocode", data)
  end

  def authenticate(data)
    post("ahoy_auth", data)
  end

  private

  def post(topic, data)
    client.put_record(
      delivery_stream_name: topic,
      record: {data: "#{data.to_json}\n"}
    )
  end

  def client
    @client ||= Aws::Firehose::Client.new
  end
end
```
