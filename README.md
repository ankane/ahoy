# Ahoy

:fire: Simple, powerful analytics for Rails

Track visits and events in Ruby, JavaScript, and native apps. Data is stored in your database by default so you can easily combine it with other data.

**Ahoy 2.0 was recently released!** See [how to upgrade](docs/Ahoy-2-Upgrade.md)

:postbox: To track emails, check out [Ahoy Email](https://github.com/ankane/ahoy_email), and for A/B testing, check out [Field Test](https://github.com/ankane/field_test)

:tangerine: Battle-tested at [Instacart](https://www.instacart.com/opensource)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'ahoy_matey'
```

And run:

```sh
bundle install
rails generate ahoy:install
rails db:migrate
```

Restart your web server, open a page in your browser, and a visit will be created :tada:

Track your first event from a controller with:

```ruby
ahoy.track "My first event", {language: "Ruby"}
```

### JavaScript & Native Apps

First, enable the API in `config/initializers/ahoy.rb`:

```ruby
Ahoy.api = true
```

And restart your web server.

For JavaScript, add to `app/assets/javascripts/application.js`:

```javascript
//= require ahoy
```

And track an event with:

```javascript
ahoy.track("My second event", {language: "JavaScript"});
```

For native apps, see the [API spec](#api-spec).

## How It Works

### Visits

When someone visits your website, Ahoy creates a visit with lots of useful information.

- **traffic source** - referrer, referring domain, landing page, search keyword
- **location** - country, region, and city
- **technology** - browser, OS, and device type
- **utm parameters** - source, medium, term, content, campaign

Use the `current_visit` method to access it.

Prevent certain Rails actions from creating visits with:

```ruby
skip_before_action :track_ahoy_visit
```

This is typically useful for APIs.

You can also defer visit tracking to JavaScript (Ahoy 1.0 behavior) with:

```ruby
Ahoy.server_side_visits = false
```

### Events

Each event has a `name` and `properties`.

There are three ways to track events.

#### JavaScript

```javascript
ahoy.track("Viewed book", {title: "The World is Flat"});
```

or track events automatically with:

```javascript
ahoy.trackAll();
```

See [Ahoy.js](https://github.com/ankane/ahoy.js) for a complete list of features.

#### Ruby

```ruby
ahoy.track "Viewed book", title: "Hot, Flat, and Crowded"
```

or track actions automatically with:

```ruby
class ApplicationController < ActionController::Base
  after_action :track_action

  protected

  def track_action
    ahoy.track "Viewed action", request.path_parameters
  end
end
```

#### Native Apps

See the [API spec](#api-spec).

### Associated Models

Say we want to associate orders with visits. Just add `visitable` to the model.

```ruby
class Order < ApplicationRecord
  visitable
end
```

When a visitor places an order, the `visit_id` column is automatically set :tada:

See where orders are coming from with simple joins:

```ruby
Order.joins(:visit).group("referring_domain").count
Order.joins(:visit).group("city").count
Order.joins(:visit).group("device_type").count
```

Here’s what the migration to add the `visit_id` column should look like:

```ruby
class AddVisitIdToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :visit_id, :bigint
  end
end
```

Customize the column and class name with:

```ruby
visitable :sign_up_visit, class_name: "Visit"
```

### Users

Ahoy automatically attaches the `current_user` to the visit. With [Devise](https://github.com/plataformatec/devise), it attaches the user even if he or she signs in after the visit starts.

With other authentication frameworks, add this to the end of your sign in method:

```ruby
ahoy.authenticate(user)
```

To see the visits for a given user, create an association:

```ruby
class User < ApplicationRecord
  has_many :visits, class_name: "Ahoy::Visit"
end
```

And use:

```ruby
User.find(123).visits
```

#### Custom User Method

Use a method besides `current_user`

```ruby
Ahoy.user_method = :true_user
```

or use a proc

```ruby
Ahoy.user_method = ->(controller) { controller.true_user }
```

#### Doorkeeper

To attach the user with [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper), be sure you have a `current_resource_owner` method in `ApplicationController`.

```ruby
class ApplicationController < ActionController::Base
  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
```

### Exclusions

Bots are excluded from tracking by default. To include them, use:

```ruby
Ahoy.track_bots = true
```

Add your own rules with:

```ruby
Ahoy.exclude_method = lambda do |controller, request|
  request.ip == "192.168.1.1"
end
```

### Visit Duration

By default, a new visit is created after 4 hours of inactivity. Change this with:

```ruby
Ahoy.visit_duration = 30.minutes
```

### Multiple Subdomains

To track visits across multiple subdomains, use:

```ruby
Ahoy.cookie_domain = :all
```

### Geocoding

Disable geocoding with:

```ruby
Ahoy.geocode = false
```

Change the job queue with:

```ruby
Ahoy.job_queue = :low_priority
```

### Token Generation

Ahoy uses random UUIDs for visit and visitor tokens by default, but you can use your own generator like [Druuid](https://github.com/recurly/druuid).

```ruby
Ahoy.token_generator = -> { Druuid.gen }
```

### Throttling

You can use [Rack::Attack](https://github.com/kickstarter/rack-attack) to throttle requests to the API.

```ruby
class Rack::Attack
  throttle("ahoy/ip", limit: 20, period: 1.minute) do |req|
    if req.path.start_with?("/ahoy/")
      req.ip
    end
  end
end
```

### Exceptions

Exceptions are rescued so analytics do not break your app. Ahoy uses [Safely](https://github.com/ankane/safely) to try to report them to a service by default. To customize this, use:

```ruby
Safely.report_exception_method = ->(e) { Rollbar.error(e) }
```

## Development

Ahoy is built with developers in mind. You can run the following code in your browser’s console.

Force a new visit

```javascript
ahoy.reset(); // then reload the page
```

Log messages

```javascript
ahoy.debug();
```

Turn off logging

```javascript
ahoy.debug(false);
```

Debug API requests in Ruby

```ruby
Ahoy.quiet = false
```

## Data Stores

Data tracked by Ahoy is sent to your data store. Ahoy ships with a data store that uses your Rails database by default. You can find it in `config/initializers/ahoy.rb`:

```ruby
class Ahoy::Store < Ahoy::DatabaseStore
end
```

There are four events data stores can subscribe to:

```ruby
class Ahoy::Store < Ahoy::BaseStore
  def track_visit(data)
    # new visit
  end

  def track_event(data)
    # new event
  end

  def geocode(data)
    # visit geocoded
  end

  def authenticate(data)
    # user authenticates
  end
end
```

Data stores are designed to be highly customizable so you can scale as you grow. Check out [examples](docs/Data-Store-Examples.md) for Kafka, RabbitMQ, Fluentd, NATS, NSQ, and Amazon Kinesis Firehose.

### Track Additional Data

```ruby
class Ahoy::Store < Ahoy::DatabaseStore
  def track_visit(data)
    data[:accept_language] = request.headers["Accept-Language"]
    super(data)
  end
end
```

Two useful methods you can use are `request` and `controller`.

### Use Different Models

```ruby
class Ahoy::Store < Ahoy::DatabaseStore
  def visit_model
    MyVisit
  end

  def event_model
    MyEvent
  end
end
```

## Explore the Data

[Blazer](https://github.com/ankane/blazer) is a great tool for exploring your data.

With ActiveRecord, you can do:

```ruby
Ahoy::Visit.group(:search_keyword).count
Ahoy::Visit.group(:country).count
Ahoy::Visit.group(:referring_domain).count
```

[Chartkick](http://chartkick.com/) and [Groupdate](https://github.com/ankane/groupdate) make it easy to visualize the data.

```erb
<%= line_chart Ahoy::Visit.group_by_day(:started_at).count %>
```

### Querying Events

Ahoy provides two methods on the event model to make querying easier.

To query on both name and properties, you can use:

```ruby
Ahoy::Event.where_event("Viewed product", product_id: 123).count
```

Or just query properties with:

```ruby
Ahoy::Event.where_props(product_id: 123).count
```

### Funnels

It’s easy to create funnels.

```ruby
viewed_store_ids = Ahoy::Event.where(name: "Viewed store").distinct.pluck(:user_id)
added_item_ids = Ahoy::Event.where(user_id: viewed_store_ids, name: "Added item to cart").distinct.pluck(:user_id)
viewed_checkout_ids = Ahoy::Event.where(user_id: added_item_ids, name: "Viewed checkout").distinct.pluck(:user_id)
```

The same approach also works with visitor tokens.

## Tutorials

- [Tracking Metrics with Ahoy and Blazer](https://gorails.com/episodes/internal-metrics-with-ahoy-and-blazer)

## API Spec

### Visits

Generate visit and visitor tokens as [UUIDs](http://en.wikipedia.org/wiki/Universally_unique_identifier), and include these values in the `Ahoy-Visit` and `Ahoy-Visitor` headers with all requests.

Send a `POST` request to `/ahoy/visits` with `Content-Type: application/json` and a body like:

```json
{
  "visit_token": "<visit-token>",
  "visitor_token": "<visitor-token>",
  "platform": "iOS",
  "app_version": "1.0.0",
  "os_version": "11.2.6"
}
```

After 4 hours of inactivity, create another visit (use the same visitor token).

### Events

Send a `POST` request to `/ahoy/events` with `Content-Type: application/json` and a body like:

```json
{
  "visit_token": "<visit-token>",
  "visitor_token": "<visitor-token>",
  "events": [
    {
      "id": "<optional-random-id>",
      "name": "Viewed item",
      "properties": {
        "item_id": 123
      },
      "time": "2018-01-01T00:00:00-07:00"
    }
  ]
}
```

## Webpacker

For Webpacker, use Yarn to install the JavaScript library:

```sh
yarn add ahoy.js
```

Then include it in your pack.

```es6
import ahoy from "ahoy.js";
```

## History

View the [changelog](https://github.com/ankane/ahoy/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/ahoy/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/ahoy/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
