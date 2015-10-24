## 1.2.1

- Fixed `SystemStackError: stack level too deep` when used with `activerecord-session_store`

## 1.2.0

- Added support for PostgreSQL `jsonb` column type
- Added Fluentd store
- Added latitude, longitude, and postal_code to visits
- Log exclusions

## 1.1.1

- Better support for Authlogic
- Added `screen_height` and `screen_width`

## 1.1.0

- Added `geocode` option
- Report errors to service by default
- Fixed association mismatch

## 1.0.2

- Fixed BSON for Mongoid 3
- Fixed Doorkeeper integration
- Fixed user tracking in overridden authenticate method

## 1.0.1

- Fixed `visitable` outside of requests

## 1.0.0

- Added support for any data store, and Mongoid out of the box
- Added `track_visits_immediately` option
- Added exception catching and reporting
- Visits expire after inactivity, not fixed interval
- Added `visit_duration` and `visitor_duration` options

## 0.3.2

- Fixed bot exclusion for visits
- Fixed user method

## 0.3.1

- Fixed visitor cookies when set on server
- Added `domain` option for server cookies

## 0.3.0

- Added `current_visit_token` and `current_visitor_token` method
- Switched to UUIDs
- Quiet endpoint requests
- Skip server-side bot events
- Added `request` argument to `exclude_method`

## 0.2.2

- Added `exclude_method` option
- Added support for batch events
- Fixed cookie encoding
- Fixed `options` variable from being modified

## 0.2.1

- Fixed IE 8 error
- Added `track_bots` option
- Added `$authenticate` event

## 0.2.0

- Added event tracking (merged ahoy_events)
- Added ahoy.js

## 0.1.8

- Fixed bug with `user_type` set to `false` instead of `nil`

## 0.1.7

- Made cookie functions public for ahoy_events

## 0.1.6

- Better user agent parser

## 0.1.5

- Added support for Doorkeeper
- Added options to `visitable`
- Added `landing_params` method

## 0.1.4

- Added `ahoy.ready()` and `ahoy.log()` for events

## 0.1.3

- Supports `current_user` from `ApplicationController`
- Added `ahoy.reset()`
- Added `ahoy.debug()`
- Added experimental support for native apps
- Prefer `ahoy` over `Ahoy`

## 0.1.2

- Attach user on Devise sign up
- Ability to specify visit model

## 0.1.1

- Made most database columns optional
- Performance hack for referer-parser

## 0.1.0

- First major release
