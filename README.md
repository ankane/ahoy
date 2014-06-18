# Ahoy

:fire: Simple, powerful analytics for Rails

Ahoy makes it easy to track visitors and users.  Track visits (sessions) and events in Ruby, JavaScript, and native apps.  Works with any data store so you can easily scale.

:postbox: To track emails, check out [Ahoy Email](https://github.com/ankane/ahoy_email).

See [upgrade instructions](#upgrading) on how to move to 1.0.

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

### ActiveRecord

#### PostgreSQL

```sh
rails generate ahoy:stores:active_record -d postgresql
rake db:migrate
```

#### MySQL and SQLite

Add [activeuuid](https://github.com/jashmenn/activeuuid) to your Gemfile.

```ruby
gem 'activeuuid', '>= 0.5.0'
```

And run:

```sh
rails generate ahoy:stores:active_record
rake db:migrate
```

If you just want visits, run:

```sh
rails generate ahoy:stores:active_record_visits
rake db:migrate
```

### Mongoid

```sh
rails generate ahoy:stores:mongoid
```

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

## How It Works

### Visits

When someone visits your website, Ahoy creates a visit with lots of useful information.

- **traffic source** - referrer, referring domain, landing page, search keyword
- **location** - country, region, and city
- **technology** - browser, OS, and device type
- **utm parameters** - source, medium, term, content, campaign

Use the `current_visit` method to access it, and the `ahoy.visit_id` and `ahoy.visitor_id` methods to get the ids.

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

See the [HTTP spec](#native-apps) until libraries are built.

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
class Ahoy::Store < Ahoy::Stores::ActiveRecord
  # add methods here
end
```

### Exclude Bots and More

Bots are excluded by default. To change this, use:

```ruby
def exclude?
  bots? || request.ip == "192.168.1.1"
end
```

### Track Additional Values

```ruby
def track_visit(options)
  super do |visit|
    visit.gclid = visit_properties.landing_params["gclid"]
  end
end
```

or

```ruby
def track_event(name, properties, options)
  super do |event|
    event.ip = request.ip
  end
end
```

### Customize User

```ruby
def user
  controller.true_user
end
```

### Report Exceptions

Exceptions are caught by default so analytics do not break your app.

To report them to a service, use:

```ruby
def report_exception(e)
  Rollbar.report_exception(e)
end
```

### Use Different Models

For ActiveRecord and Mongoid stores

```ruby
def visit_model
  CustomVisit
end

def event_model
  CustomEvent
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
  after_filter :track_action

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

```ruby
class Order < ActiveRecord::Base
  visitable
end
```

When a visitor places an order, the `visit_id` column is automatically set.

:tada: Magic!

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

### Track Visits on the Server

The visitor and visit id are generated on the server, but the `track_visit` method is not called until the JavaScript library executes.  This prevents users with cookies disabled from creating multiple visits and ensures visits are not created for API endpoints.  Change this with:

```ruby
Ahoy.track_visits_on_server = true
```

**Note:** At the moment, geocoding is performed in the foreground, which can slow down the first page load.

If you add this to your `ApplicationController`, be sure to exclude API endpoints with:

```ruby
skip_before_filter :track_ahoy_visit
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

Here are ways to do it with ActiveRecord.

```ruby
Visit.group(:search_keyword).count
Visit.group(:country).count
Visit.group(:referring_domain).count
```

[Chartkick](http://chartkick.com/) and [Groupdate](https://github.com/ankane/groupdate) make it super easy to visualize the data.

```erb
<%= line_chart Visit.group_by_day(:created_at).count %>
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

The same approach also works with visitor ids.

## Native Apps

### Visits

When a user launches the app, create a visit.

Generate a `visit_id` and `visitor_id` as [UUIDs](http://en.wikipedia.org/wiki/Universally_unique_identifier).

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

## Upgrading

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

You made it!  Now, take advantage of Ahoy’s awesome new features, like exception reporting.

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

- simple dashboard
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
