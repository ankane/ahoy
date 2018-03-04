# Ahoy 2 Upgrade

Ahoy 2.0 brings a number of exciting changes:

- jQuery is no longer required
- Uses `navigator.sendBeacon` by default in supported browsers
- Simpler interface for data stores

## How to Upgrade

Update your Gemfile:

```ruby
gem 'ahoy_matey', '~> 2'
```

And run:

```sh
bundle update ahoy_matey
```

Add to `config/initializers/ahoy.rb`:

```ruby
Ahoy.api = true
Ahoy.server_side_visits = false
```

You can also try the new `Ahoy.server_side_visits = :when_needed` to automatically create visits server-side when needed for events and `visitable`.

If you use `visitable`, add `class_name` to each instance:

```ruby
visitable class_name: "Visit"
```

Then follow the instructions for your data store.

- [ActiveRecordTokenStore](#activerecordtokenstore)
- [ActiveRecordStore](#activerecordstore)
- [MongoidStore](#mongoidstore)
- [Others](#others)

## Data Stores

### ActiveRecordTokenStore

In `config/initializers/ahoy.rb`, replace `Ahoy::Store` with:

```ruby
class Ahoy::Store < Ahoy::DatabaseStore
  def visit_model
    Visit
  end
end
```

### ActiveRecordStore

Add [uuidtools](https://github.com/sporkmonger/uuidtools) to your Gemfile.

In `config/initializers/ahoy.rb`, replace `Ahoy::Store` with:

```ruby
class Ahoy::Store < Ahoy::DatabaseStore
  def track_visit(data)
    data[:id] = ensure_uuid(data.delete(:visit_token))
    data[:visitor_id] = ensure_uuid(data.delete(:visitor_token))
    super(data)
  end

  def track_event(data)
    data[:id] = ensure_uuid(data.delete(:event_id))
    super(data)
  end

  def visit
    @visit ||= visit_model.find_by(id: ensure_uuid(ahoy.visit_token)) if ahoy.visit_token
  end

  def visit_model
    Visit
  end

  UUID_NAMESPACE = UUIDTools::UUID.parse("a82ae811-5011-45ab-a728-569df7499c5f")

  def ensure_uuid(id)
    UUIDTools::UUID.parse(id).to_s
  rescue
    UUIDTools::UUID.sha1_create(UUID_NAMESPACE, id).to_s
  end
end
```

### MongoidStore

In `config/initializers/ahoy.rb`, replace `Ahoy::Store` with:

```ruby
class Ahoy::Store < Ahoy::DatabaseStore
  def track_visit(data)
    data[:_id] = binary_uuid(data.delete(:visit_token))
    data[:visitor_id] = binary_uuid(data.delete(:visitor_token))
    super(data)
  end

  def track_event(data)
    data[:_id] = binary_uuid(data.delete(:event_id))
    super(data)
  end

  def geocode(data)
    visit_model.where(id: binary_uuid(ahoy.visit_token)).find_one_and_update({"$set": data}, {upsert: true})
  end

  def visit
    @visit ||= visit_model.where(id: binary_uuid(ahoy.visit_token)).first if ahoy.visit_token
  end

  def visit_model
    Visit
  end

  def binary_uuid(token)
    token = token.delete("-")
    if defined?(::BSON)
      ::BSON::Binary.new(token, :uuid)
    elsif defined?(::Moped::BSON)
      ::Moped::BSON::Binary.new(:uuid, token)
    else
      token
    end
  end
end
```

### Others

Check out the [data store examples](Data-Store-Examples.md).

## Throttling

Throttling was removed due to limited practical usefulness. See [instructions for adding it back](../README.md#throttling) if you need it.

## Options

- The `mount` option was renamed to `api`
- The `track_visits_immediately` option was renamed to `server_side_visits`
