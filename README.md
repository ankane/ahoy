# Ahoy

:fire: Simple, powerful visit tracking for Rails

:exclamation: Not ready for production just yet

You get:

- traffic source - referrer, referring domain, landing page, search keyword
- location - country, region, and city
- technology - browser, OS, and device type
- utm parameters - source, medium, term, content, campaign

It’s all stored in **your database** so you can easily combine it with other data.

See which campaigns generate the most revenue effortlessly.

```ruby
Order.joins(:visit).group("utm_campaign").sum(:revenue)
```

## Ready, Set, Go

Add this line to your application’s Gemfile:

```ruby
gem "ahoy_matey"
```

And run the generator. This creates a migration to store visits.

```sh
rails generate ahoy:install
rake db:migrate
```

Lastly, include the javascript file in `app/assets/javascripts/application.js` after jQuery.

```javascript
//= require jquery
//= require ahoy
```

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

## The Power

This information is great on its own, but super powerful when combined with other models.

You can associate the visit with any model. For instance, when someone places an order:

```ruby
Order.create(
  visit_id: current_visit.try(:id),
  # ... other attributes ...
)
```

To see where most of your orders are coming from, create an association:

```ruby
class Order < ActiveRecord::Base
  belongs_to :visit
end
```

And query away:

```ruby
Order.joins(:visit).group("referring_domain").count
Order.joins(:visit).group("device_type").count
Order.joins(:visit).group("city").count
```

## Users

Ahoy automatically attaches the `current_user` to the `current_visit`.

With [Devise](https://github.com/plataformatec/devise), it will attach the user even if he / she signs in after the visit starts.

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

## Location

Ahoy uses [Geocoder](https://github.com/alexreisner/geocoder) for IP-based geocoding.

## UTM Parameters

Use UTM Parameters to track campaigns. [This is great for emails and social media](http://www.thunderseo.com/blog/utm-parameters/). Just add them to your links and Ahoy will pick them up.

```
http://datakick.org/?utm_medium=email&utm_campaign=newsletter&utm_source=newsletter-2014-03
```

or

```
http://datakick.org/?utm_medium=twitter&utm_campaign=social&utm_source=tweet123
```

## Features

- Excludes bots
- Degrades gracefully when cookies are disabled

## TODO

- set visit_id automatically on `visitable` models
- simple dashboard
- hook to store additional fields
- turn off modules

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/ahoy/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/ahoy/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
