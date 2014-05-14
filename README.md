# Ahoy

:fire: Simple, powerful analytics for Rails

Visits are stored in **your database** so you can easily combine them with other data.

You get:

- **traffic source** - referrer, referring domain, landing page, search keyword
- **location** - country, region, and city
- **technology** - browser, OS, and device type
- **utm parameters** - source, medium, term, content, campaign

Track events in:

- JavaScript
- Ruby
- Native apps

And store them wherever you’d like - your database, logs, external services, or all of them.

:postbox: To track emails, check out [Ahoy Email](https://github.com/ankane/ahoy_email).

No Ruby? Check out [Ahoy.js](https://github.com/ankane/ahoy.js).

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'ahoy_matey'
```

And run the generator. This creates a model to store visits.

```sh
rails generate ahoy:install
rake db:migrate
```

Lastly, include the javascript file in `app/assets/javascripts/application.js` after jQuery.

```javascript
//= require jquery
//= require ahoy
```

We recommend using traditional analytics services like [Google Analytics](http://www.google.com/analytics/) as well.

## How It Works

When someone visits your website, Ahoy creates a visit with lots of useful information.

Use the `current_visit` method to access it.

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

### Native Apps

When a user launches the app, create a visit.  Send a `POST` request to `/ahoy/visits` with:

- platform - `iOS`, `Android`, etc.
- app_version - `1.0.0`
- os_version - `7.0.6`
- visitor_token - if you have one

The endpoint will return a JSON response like:

```json
{
  "visit_token": "8tx2ziymkwa1WlppnkqxyaBaRlXrEQ3K",
  "visitor_token": "hYBIV0rBfrIUAiArWweiECt4N9pyiygN"
}
```

Send the visit token in the `Ahoy-Visit` header for all requests.

After 4 hours, create another visit and use the updated visit token.

## Events

Each event has a `name` and `properties`.

There are three ways to track events.

#### JavaScript

```javascript
ahoy.track("Viewed book", {title: "The World is Flat"});
```

or track all views and clicks with:

```javascript
ahoy.trackAll();
```

#### Ruby

```ruby
ahoy.track "Viewed book", title: "Hot, Flat, and Crowded"
```

#### Native Apps

Send a `POST` request to `/ahoy/events` with:

- name
- properties
- user token (depends on your authentication framework)
- `Ahoy-Visit` header

Requests should have `Content-Type: application/json`.

### Storing Events

You choose how to store events.

#### ActiveRecord

Create an `Ahoy::Event` model to store events.

```sh
rails generate ahoy:events:active_record
rake db:migrate
```

#### Custom

Create your own subscribers in `config/initializers/ahoy.rb`.

```ruby
class LogSubscriber

  def track(name, properties, options = {})
    data = {
      name: name,
      properties: properties,
      time: options[:time].to_i,
      visit_id: options[:visit].try(:id),
      user_id: options[:user].try(:id),
      ip: options[:controller].try(:request).try(:remote_ip)
    }
    Rails.logger.info data.to_json
  end

end

# and add it
Ahoy.subscribers << LogSubscriber.new
```

Add as many subscribers as you’d like.

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

To track visits across multiple subdomains, add this **before** the javascript files.

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

## Upgrading

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

## History

View the [changelog](https://github.com/ankane/ahoy/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/ahoy/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/ahoy/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
