# Ahoy

:fire: Simple, powerful visit tracking for Rails

In under a minute, start learning more about your visitors.

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

## What You Get

When a person visits your website, Ahoy creates a visit with lots of useful information.

Use the `current_visit` method to access it.

The information is great on it’s own, but super powerful when combined with other models.

You can store the visit id on any model. For instance, when someone places an order:

```ruby
class Order < ActiveRecord::Base
  visitable # needs better name
end
```

The visit_id column will be automatically set. Magic!

When you want to explore where most orders are coming from, you can do a number of queries.

```ruby
Order.joins(:visit).group("referring_domain").count
Order.joins(:visit).group("device_type").count
Order.joins(:visit).group("city").count
```

## User Model

```ruby
class User < ActiveRecord::Base
  has_many :visits, class_name: "Ahoy::Visit"
end
```

## Features

- Excludes bots
- Degrades gracefully when cookies are disabled
- Gets campaign from utm_campaign parameter

## TODO

- better readme
- model integration
- update visit when user logs in
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
