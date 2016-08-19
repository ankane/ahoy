# Ahoy

Ahoy provides a solid foundation to track visits and events in Ruby, JavaScript, and native apps. Works with any data store so you can easily scale.

:tangerine: Battle-tested at [Instacart](https://www.instacart.com/opensource)

:postbox: To track emails, check out [Ahoy Email](https://github.com/ankane/ahoy_email).

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'ahoy_matey'
```

And add the javascript file in `app/assets/javascripts/application.js` after jQuery.

```javascript
//= require jquery
//= require ahoy
```

## Choose a Data Store

Ahoy supports a number of data stores out of the box.  You can start with one of them and customize as needed, or create your own store from scratch.

- [PostgreSQL, MySQL, or SQLite](#postgresql-mysql-or-sqlite)
- [MongoDB](#mongodb)
- [Kafka](#kafka)
- [Fluentd](#fluentd)
- [RabbitMQ](#rabbitmq)
- [Amazon Kinesis Firehose](#amazon-kinesis-firehose)
- [Logs](#logs)
- [Custom](#custom)

### PostgreSQL, MySQL, or SQLite

Run:

```sh
rails generate ahoy:stores:active_record
rake db:migrate
```

### MongoDB

```sh
rails generate ahoy:stores:mongoid
```

### Kafka

Add [ruby-kafka](https://github.com/zendesk/ruby-kafka) to your Gemfile.

```ruby
gem 'ruby-kafka'
```

And run:

```sh
rails generate ahoy:stores:kafka
```

Use `ENV["KAFKA_URL"]` to configure.

### Fluentd

Add [fluent-logger](https://github.com/fluent/fluent-logger-ruby) to your Gemfile.

```ruby
gem 'fluent-logger'
```

And run:

```sh
rails generate ahoy:stores:fluentd
```

Use `ENV["FLUENTD_HOST"]` and `ENV["FLUENTD_PORT"]` to configure.

### RabbitMQ

Add [bunny](https://github.com/ruby-amqp/bunny) to your Gemfile.

```ruby
gem 'bunny'
```

And run:

```sh
rails generate ahoy:stores:bunny
```

Use `ENV["RABBITMQ_URL"]` to configure.

### Amazon Kinesis Firehose

Add [aws-sdk](https://github.com/aws/aws-sdk-ruby) to your Gemfile.

```ruby
gem 'aws-sdk', '>= 2.0.0'
```

And run:

```sh
rails generate ahoy:stores:kinesis_firehose
```

Configure delivery streams and credentials in the initializer.

### Logs

```sh
rails generate ahoy:stores:log
```

This logs visits to `log/visits.log` and events to `log/events.log`.

### Custom

```sh
rails generate ahoy:stores:custom
```

This creates a class for you to fill out.

```ruby
class Ahoy::Store < Ahoy::Stores::BaseStore
  def track_visit(options)
  end

  def track_event(name, properties, options)
  end
end
```

See the [ActiveRecordStore](https://github.com/ankane/ahoy/blob/master/lib/ahoy/stores/active_record_store.rb) for an example.

## How It Works

### Visits

When someone visits your website, Ahoy creates a visit with lots of useful information.

- **traffic source** - referrer, referring domain, landing page, search keyword
- **location** - country, region, and city
- **technology** - browser, OS, and device type
- **utm parameters** - source, medium, term, content, campaign

Use the `current_visit` method to access it.

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

#### Native Apps

See the [HTTP spec](#native-apps-1) until libraries are built.

### Users

Ahoy automatically attaches the `current_user` to the visit.

With [Devise](https://github.com/plataformatec/devise), it will attach the user even if he or she signs in after the visit starts.

With other authentication frameworks, add this to the end of your sign in method:

```ruby
ahoy.authenticate(user)
```

## Customize the Store

Stores are built to be highly customizable.

```ruby
class Ahoy::Store < Ahoy::Stores::ActiveRecordTokenStore
  # add methods here
end
```

### Exclude Bots and More

Exclude visits and events from being tracked with:

```ruby
class Ahoy::Store < Ahoy::Stores::ActiveRecordTokenStore
  def exclude?
    bot? || request.ip == "192.168.1.1"
  end
end
```

Bots are excluded by default.

### Track Additional Values

```ruby
class Ahoy::Store < Ahoy::Stores::ActiveRecordTokenStore
  def track_visit(options)
    super do |visit|
      visit.gclid = visit_properties.landing_params["gclid"]
    end
  end

  def track_event(name, properties, options)
    super do |event|
      event.ip = request.ip
    end
  end
end
```

### Customize User

If you use a method other than `current_user`, set it here:

```ruby
class Ahoy::Store < Ahoy::Stores::ActiveRecordTokenStore
  def user
    controller.true_user
  end
end
```

### Report Exceptions

Exceptions are rescued so analytics do not break your app. Ahoy uses [Safely](https://github.com/ankane/safely) to try to report them to a service by default.

To customize this, use:

```ruby
Safely.report_exception_method = proc { |e| Rollbar.error(e) }
```

### Use Different Models

For ActiveRecord and Mongoid stores

```ruby
class Ahoy::Store < Ahoy::Stores::ActiveRecordTokenStore
  def visit_model
    CustomVisit
  end

  def event_model
    CustomEvent
  end
end
```

## More Features

### Automatic Tracking

Page views

```javascript
ahoy.trackView();
```

Clicks

```javascript
ahoy.trackClicks();
```

Rails actions

```ruby
class ApplicationController < ActionController::Base
  after_action :track_action

  protected

  def track_action
    ahoy.track "Processed #{controller_name}##{action_name}", request.filtered_parameters
  end
end
```

### Multiple Subdomains

To track visits across multiple subdomains, use:

```ruby
Ahoy.cookie_domain = :all
```

### Visit Duration

By default, a new visit is created after 4 hours of inactivity.

Change this with:

```ruby
Ahoy.visit_duration = 30.minutes
```

### ActiveRecord

Let’s associate orders with visits.

First, generate a migration and add a `visit_id` column.

```ruby
class AddVisitIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :visit_id, :integer
  end
end
```

**Note**: Use the `uuid` column type if the `id` column on `visits` is a `uuid`.

Then, add `visitable` to the model.

```ruby
class Order < ActiveRecord::Base
  visitable
end
```

When a visitor places an order, the `visit_id` column is automatically set. :tada:

Customize the column and class name with:

```ruby
visitable :sign_up_visit, class_name: "Visit"
```

### Doorkeeper

To attach the user with [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper), be sure you have a `current_resource_owner` method in `ApplicationController`.

```ruby
class ApplicationController < ActionController::Base
  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
```

### Geocoding

By default, geocoding is performed inline. For performance, move it to the background with:

```ruby
Ahoy.geocode = :async
```

For Rails 4.0 and 4.1, you’ll need to add [activejob_backport](https://github.com/ankane/activejob_backport).

To change the queue name (`ahoy` by default), use:

```ruby
Ahoy.job_queue = :low_priority
```

Or disable geocoding with:

```ruby
Ahoy.geocode = false
```

### Track Visits Immediately

Visitor and visit ids are generated on the first request (so you can use them immediately), but the `track_visit` method isn’t called until the JavaScript library posts to the server.  This prevents browsers with cookies disabled from creating multiple visits and ensures visits are not created for API endpoints.  Change this with:

```ruby
Ahoy.track_visits_immediately = true
```

**Note:** It’s highly recommended to perform geocoding in the background with this option.

You can exclude API endpoints and other actions with:

```ruby
skip_before_action :track_ahoy_visit
```

## Development

Ahoy is built with developers in mind.  You can run the following code in your browser’s console.

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

Debug endpoint requests in Ruby

```ruby
Ahoy.quiet = false
```

## Explore the Data

How you explore the data depends on the data store used.

For SQL databases, you can use [Blazer](https://github.com/ankane/blazer) to easily generate charts and dashboards.

With ActiveRecord, you can do:

```ruby
Visit.group(:search_keyword).count
Visit.group(:country).count
Visit.group(:referring_domain).count
```

[Chartkick](http://chartkick.com/) and [Groupdate](https://github.com/ankane/groupdate) make it easy to visualize the data.

```erb
<%= line_chart Visit.group_by_day(:started_at).count %>
```

See where orders are coming from with simple joins:

```ruby
Order.joins(:visit).group("referring_domain").count
Order.joins(:visit).group("city").count
Order.joins(:visit).group("device_type").count
```

To see the visits for a given user, create an association:

```ruby
class User < ActiveRecord::Base
  has_many :visits
end
```

And use:

```ruby
user = User.first
user.visits
```

### Create Funnels

```ruby
viewed_store_ids = Ahoy::Event.where(name: "Viewed store").uniq.pluck(:user_id)
added_item_ids = Ahoy::Event.where(user_id: viewed_store_ids, name: "Added item to cart").uniq.pluck(:user_id)
viewed_checkout_ids = Ahoy::Event.where(user_id: added_item_ids, name: "Viewed checkout").uniq.pluck(:user_id)
```

The same approach also works with visitor tokens.

### Querying Properties

With ActiveRecord, use:

```ruby
Ahoy::Event.where(name: "Viewed product").where_properties(product_id: 123).count
```

**Note:** If you get a `NoMethodError`, upgrade Ahoy and add `include Ahoy::Properties` to your model.

## Native Apps

### Visits

When a user launches the app, create a visit.

Generate a `visit_token` and `visitor_token` as [UUIDs](http://en.wikipedia.org/wiki/Universally_unique_identifier).

Send these values in the `Ahoy-Visit` and `Ahoy-Visitor` headers with all requests.

Send a `POST` request to `/ahoy/visits` with:

- platform - `iOS`, `Android`, etc.
- app_version - `1.0.0`
- os_version - `7.0.6`

After 4 hours of inactivity, create another visit and use the updated visit id.

### Events

Send a `POST` request as `Content-Type: application/json` to `/ahoy/events` with:

- id - `5aea7b70-182d-4070-b062-b0a09699ad5e` - UUID
- name - `Viewed item`
- properties - `{"item_id": 123}`
- time - `2014-06-17T00:00:00-07:00` - [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601)
- `Ahoy-Visit` and `Ahoy-Visitor` headers
- user token (depends on your authentication framework)

Use an array to pass multiple events at once.

## Reference

By default, Ahoy create endpoints at `/ahoy/visits` and `/ahoy/events`. To disable, use:

```ruby
Ahoy.mount = false
```

## Upgrading

### 1.4.0

There’s nothing to do, but it’s worth noting the default store was changed from `ActiveRecordStore` to `ActiveRecordTokenStore` for new installations.

### json -> jsonb

Create a migration to add a new `jsonb` column.

```ruby
rename_column :ahoy_events, :properties, :properties_json
add_column :ahoy_events, :properties, :jsonb
```

Restart your web server immediately afterwards, as Ahoy will rescue and report errors until then.

Sync the new column.

```ruby
Ahoy::Event.where(properties: nil).select(:id).find_in_batches do |events|
  Ahoy::Event.where(id: events.map(&:id)).update_all("properties = properties_json::jsonb")
end
```

Then create a migration to drop the old column.

```ruby
remove_column :ahoy_events, :properties_json
```

### 1.0.0

Add the following code to the end of `config/intializers/ahoy.rb`.

```ruby
class Ahoy::Store < Ahoy::Stores::ActiveRecordTokenStore
  uses_deprecated_subscribers
end
```

If you use `Ahoy::Event` to track events, copy it into your project.

```ruby
module Ahoy
  class Event < ActiveRecord::Base
    self.table_name = "ahoy_events"

    belongs_to :visit
    belongs_to :user, polymorphic: true

    serialize :properties, JSON
  end
end
```

That’s it!  To fix deprecations, keep reading.

#### Visits

Remove `ahoy_visit` from your visit model and replace it with:

```ruby
class Visit < ActiveRecord::Base
  belongs_to :user, polymorphic: true
end
```

#### Subscribers

Remove `uses_deprecated_subscribers` from `Ahoy::Store`.

If you have a custom subscriber, copy the `track` method to `track_event` in `Ahoy::Store`.

```ruby
class Ahoy::Store < Ahoy::Stores::ActiveRecordTokenStore
  def track_event(name, properties, options)
    # code copied from the track method in your subscriber
  end
end
```

#### Authentication

Ahoy no longer tracks the `$authenticate` event automatically.

To restore this behavior, use:

```ruby
class Ahoy::Store < Ahoy::Stores::ActiveRecordTokenStore
  def authenticate(user)
    super
    ahoy.track "$authenticate"
  end
end
```

#### Global Options

Replace the `Ahoy.user_method` with `user` method, and replace `Ahoy.track_bots` and `Ahoy.exclude_method` with `exclude?` method.

Skip this step if you do not use these options.

```ruby
class Ahoy::Store < Ahoy::Stores::ActiveRecordTokenStore
  def user
    # logic from Ahoy.user_method goes here
    controller.true_user
  end

  def exclude?
    # logic from Ahoy.track_bots and Ahoy.exclude_method goes here
    bot? || request.ip == "192.168.1.1"
  end
end
```

You made it!  Now, take advantage of Ahoy’s awesome new features, like easy customization and exception reporting.

### 0.3.0

Starting with `0.3.0`, visit and visitor tokens are now UUIDs.

### 0.1.6

In `0.1.6`, a big improvement was made to `browser` and `os`. Update existing visits with:

```ruby
Visit.find_each do |visit|
  visit.set_technology
  visit.save! if visit.changed?
end
```

## TODO

- real-time dashboard of visits and events
- more events for append only stores
- turn off modules

## No Ruby?

Check out [Ahoy.js](https://github.com/ankane/ahoy.js).

## History

View the [changelog](https://github.com/ankane/ahoy/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/ahoy/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/ahoy/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
