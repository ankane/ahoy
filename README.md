# Ahoy

:fire: Simple, powerful visit tracking for Rails.

In under a minute, start learning more about your visitors.

- traffic source - referrer, referring domain, campaign, landing page
- location - country, region, and city
- technology - browser, OS, and device type

It’s all stored in **your database** so you can easily combine it with other models.

## Ready, Set, Go!

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

- traffic source (referrer, referring domain, campaign, landing page)
- location (country, region, and city)
- technology (browser, OS, and device type)

This information is great on it’s own, but super powerful when combined with other models.

You can store the visit id on any model. For instance, when someone places an order:

```ruby
Order.create!(
  ahoy_visit_id: ahoy_visit.id,
  # ... more attributes ...
)
```

When you want to explore where most orders are coming from, you can do a number of queries.

```ruby
Order.joins(:ahoy_visits).group("referring_domain").count
Order.joins(:ahoy_visits).group("city").count
Order.joins(:ahoy_visits).group("device_type").count
```

## Features

- Excludes search engines
- Gracefully degrades when cookies are disabled
- Gets campaign from utm_campaign parameter

# How It Works

When a user visits your website for the first time, the Javascript library generates a unique visit and visitor id.

It sends the event to the server.

A visit cookie is set for 4 hours, and a visitor cookie is set for 2 years.

## TODO

- better readme
- model integration
- update visit when user logs in
- better browser / OS detection
- set ahoy_visit_id automatically on `visitable` models

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/ahoy/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/ahoy/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
