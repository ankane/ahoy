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

```sh
rails generate ahoy:stores:active_record
rake db:migrate
```

If you just want visits, run:

```sh
rails generate ahoy:stores:active_record_visits
rake db:migrate
```

### PostgreSQL 9.3 [coming soon]

Just like the ActiveRecord store, but more performant.

```sh
rails generate ahoy:stores:active_record_postgresql
rake db:migrate
```

### Mongoid [coming soon]

```sh
rails generate ahoy:stores:mongoid
```

### Logs

```ruby
rails generate ahoy:stores:log
```

This logs visits to `log/visits.log` and events to `log/events.log`.

### Custom

Create an initializer `config/initializers/ahoy.rb` with:

```ruby
Ahoy.store = CassandraStore.new
```

```ruby
class CassandraStore

  def track_event(name, properties, options)

  end

  def track_visit(ahoy)

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

Use the `current_visit` method to access it.

`visit_token` and `visitor_token` methods

### ActiveRecord

Explore your visits with queries like:

```ruby
Visit.group(:search_keyword).count
Visit.group(:country).count
Visit.group(:referring_domain).count
```

[Chartkick](http://chartkick.com/) and [Groupdate](https://github.com/ankane/groupdate) make it super easy to visualize the data.

```erb
<%= line_chart Visit.group_by_day(:created_at).count %>
```

### The Power

This information is great on its own, but super powerful when combined with other models.

Let’s associate orders with visits.

```ruby
class Order < ActiveRecord::Base
  visitable
end
```

When a visitor places an order, the `visit_id` column is automatically set.

:tada: Magic!

See where orders are coming from with simple joins:

```ruby
Order.joins(:visit).group("referring_domain").count
Order.joins(:visit).group("city").count
Order.joins(:visit).group("device_type").count
```

### Users

Ahoy automatically attaches the `current_user` to the `current_visit`.

With [Devise](https://github.com/plataformatec/devise), it will attach the user even if he / she signs in after the visit starts.

With other authentication frameworks, add this to the end of your sign in method:

```ruby
if current_visit and !current_visit.user
  current_visit.user = current_user
  current_visit.save!
end
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

### UTM Parameters

Use UTM parameters to track campaigns. [This is great for emails and social media](http://www.thunderseo.com/blog/utm-parameters/). Just add them to your links and Ahoy will pick them up.

```
http://datakick.org/?utm_medium=email&utm_campaign=newsletter&utm_source=newsletter-2014-03
```

or

```
http://datakick.org/?utm_medium=twitter&utm_campaign=social&utm_source=tweet123
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

### More

- Excludes bots
- Degrades gracefully when cookies are disabled
- Don’t need a field? Just remove it from the migration
- Visits are 4 hours by default

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

## Reference

To track visits across multiple subdomains, you must set the domain in two places (at the moment).

Add this to the `config/initializers/ahoy.rb` initializer:

```ruby
Ahoy.domain = "yourdomain.com"
```

and add this **before** the javascript files:

```javascript
var ahoy = {"domain": "yourdomain.com"};
```

Change the platform on the web

```javascript
var ahoy = {"platform": "Mobile Web"}
```

Track additional values

```ruby
class Visit < ActiveRecord::Base
  ahoy_visit

  before_create :set_gclid

  def set_gclid
    self.gclid = landing_params["gclid"]
  end

end
```

Use a method besides `current_user`

```ruby
Ahoy.user_method = :true_user
```

or use a Proc

```ruby
Ahoy.user_method = proc {|controller| controller.current_user }
```

Customize visitable

```ruby
visitable :sign_up_visit, class_name: "Visit"
```

Track view

```javascript
ahoy.trackView();
```

Track clicks

```javascript
ahoy.trackClicks();
```

Track all Rails actions

```ruby
class ApplicationController < ActionController::Base
  after_filter :track_action

  protected

  def track_action
    ahoy.track "Hit action", request.filtered_parameters
  end
end
```

Use a different model for visits

```ruby
Ahoy.visit_model = UserVisit

# fix for Rails reloader in development
ActionDispatch::Reloader.to_prepare do
  Ahoy.visit_model = UserVisit
end
```

Use a different model for events

```ruby
Ahoy.subscribers << Ahoy::Subscribers::ActiveRecord.new(model: Event)
```

Exclude visits and events

```ruby
Ahoy.exclude_method = proc do |controller, request|
  request.ip == "192.168.1.1"
end
```

Track bots

```ruby
Ahoy.track_bots = true
```

## Upgrading

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
