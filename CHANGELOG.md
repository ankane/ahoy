## 3.0.1

- Made `Ahoy::Tracker` work outside of requests
- Fixed storage of `false` values with customized store
- Fixed error with `user_method` and `Rails::InfoController`
- Gracefully handle `ActionDispatch::RemoteIp::IpSpoofAttackError`

## 3.0.0

- Made Device Detector the default user agent parser
- Made v2 the default bot detection version
- Removed a large number of dependencies
- Removed search keyword detection (most search engines today prevent this)
- Removed support for Rails < 5

## 2.2.1

- Updated Ahoy.js to 0.3.4
- Fixed v2 bot detection
- Added latitude and longitude to installation

## 2.2.0

- Added `amp_event` helper
- Improved bot detection for Device Detector

## 2.1.0

- Added option for IP masking
- Added option to use anonymity sets instead of cookies
- Added `user_agent_parser` option
- Fixed `visitable` for Rails 4.2
- Removed `search_keyword` from new installs

## 2.0.2

- Fixed error on duplicate records
- Fixed message when visit not found for geocoding
- Better compatibility with GeoLite2
- Better browser compatibility for Ahoy.js

## 2.0.1

- Added `Ahoy.server_side_visits = :when_needed` to automatically create visits server-side when needed for events and `visitable`
- Better handling of visit duration and expiration in JavaScript

## 2.0.0

- Removed dependency on jQuery
- Use `navigator.sendBeacon` by default in supported browsers
- Added `geocode` event
- Added `where_event` method for querying events
- Added support for `visitable` and `where_props` to Mongoid
- Added `preserve_callbacks` option
- Use `json` for MySQL by default
- Fixed log silencing

Breaking changes

- Simpler interface for data stores
- Renamed `track_visits_immediately` to `server_side_visits` and enabled by default
- Renamed `mount` option to `api` and disabled by default
- Enabled `protect_from_forgery` by default
- Removed deprecated options
- Removed throttling
- Removed most built-in stores
- Removed support for Rails < 4.2

## 1.6.1

- Added `gin` index on properties for events
- Fixed `visitable` options when name not provided

## 1.6.0

- Added support for Rails 5.1

## 1.5.5

- Added support for Rails API
- Added NATS and NSQ stores

## 1.5.4

- Fixed issue with duplicate events
- Added support for PostGIS for `where_properties`

## 1.5.3

- Fixed error with Rails 5 and Mongoid 6
- Fixed regression with server not generating visit and visitor tokens
- Accept UTM parameters as request parameters (for native apps)

## 1.5.2

- Better support for Rails 5

## 1.5.1

- Restored throttling after removing side effects

## 1.5.0

- Removed throttling due to unintended side effects with its implementation
- Ensure basic token requirements
- Fixed visit recreation on cookie expiration
- Fixed issue where `/ahoy/visits` is called indefinitely when `Ahoy.cookie_domain = :all`

## 1.4.2

- Fixed issues with `where_properties`

## 1.4.1

- Added `where_properties` method
- Added Kafka store
- Added `mount` option
- Use less intrusive version of `safely`

## 1.4.0

- Use `ActiveRecordTokenStore` by default (integer instead of uuid for id)
- Detect database for `rails g ahoy:stores:active_record` for easier installation
- Use `safely` as default exception handler
- Fixed issue with log silencer
- Use multi-column indexes on `ahoy_events` table creation

## 1.3.1

- Raise errors in test environment

## 1.3.0

- Added throttling
- Added `max_content_length` and `max_events_per_request`

## 1.2.2

- Fixed issue with latest version of `browser` gem
- Added support for RabbitMQ
- Added support for Amazon Kinesis Firehose
- Fixed deprecation warnings in Rails 5

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
