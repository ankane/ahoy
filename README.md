# Ahoy

:fire: Simple, powerful analytics for Rails

Ahoy makes it easy to track visitors and users.  Track visits (sessions) and events in Ruby, JavaScript, and native apps.  Works with any data store so you easily scale.

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

### ActiveRecord

#### PostgreSQL 9.2+

```sh
rails generate ahoy:stores:active_record -d postgresql
rake db:migrate
```

#### Other

Add [activeuuid](https://github.com/ankane/activeuuid) to your Gemfile.

```ruby
gem 'activeuuid', github: 'ankane/activeuuid' # use this fork for now
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
def track_visit
  super do |visit|
    visit.gclid = landing_params["gclid"]
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

To track visits across multiple subdomains, you must set the domain in two places (at the moment).

Add this to the `config/initializers/ahoy.rb` initializer:

```ruby
Ahoy.domain = "yourdomain.com"
```

and add this **before** the javascript files:

```javascript
var ahoy = {"domain": "yourdomain.com"};
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

Customize visitable

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

## Native Apps

Libraries for iOS and Android are coming soon. Until then, here’s the HTTP spec.

### Visits

When a user launches the app, create a visit.  Send a `POST` request to `/ahoy/visits` with:

- platform - `iOS`, `Android`, etc.
- app_version - `1.0.0`
- os_version - `7.0.6`
- visit_token - `505f6201-8e10-44cf-ba1c-37271c8d0125`
- visitor_token - `db3b1a8f-302b-42df-9cd0-06875f549474`

Tokens must be [UUIDs](http://en.wikipedia.org/wiki/Universally_unique_identifier).

Send the visit and visitor tokens in the `Ahoy-Visit` and `Ahoy-Visitor` headers with all requests.

After 4 hours, create another visit and use the updated visit token.

### Events

Send a `POST` request to `/ahoy/events` with:

- id (generated UUID)
- name
- properties
- time ([ISO 8601](https://en.wikipedia.org/wiki/ISO_8601))
- `Ahoy-Visit` and `Ahoy-Visitor` headers
- user token (depends on your authentication framework)

Requests should have `Content-Type: application/json`.

Use an array to pass multiple events at once.

## Upgrading

### 1.0.0

Ahoy is now database agnostic.

#### Global Options

- Replace `Ahoy.user_method` with `user` method
- Replace `Ahoy.track_bots` and `Ahoy.exclude_method` with `exclude?` method

#### Visit Model

- Replace `ahoy_visit` with `belongs_to :user, polymorphic: true`
- For storing additional values, use `track_event` method

#### Subscribers

- Copy `track` method in subscribers to `track_events` method in `Ahoy::Store`

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

- better readme
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
