class Visit
  include Mongoid::Document

  # associations
  belongs_to :user

  # required
  field :visitor_id, type: <%= @visitor_id_type %>

  # the rest are recommended but optional
  # simply remove the columns you don't want

  # standard
  field :ip, type: String
  field :user_agent, type: String
  field :referrer, type: String
  field :landing_page, type: String

  # traffic source
  field :referring_domain, type: String
  field :search_keyword, type: String

  # technology
  field :browser, type: String
  field :os, type: String
  field :device_type, type: String

  # location
  field :country, type: String
  field :region, type: String
  field :city, type: String

  # utm parameters
  field :utm_source, type: String
  field :utm_medium, type: String
  field :utm_term, type: String
  field :utm_content, type: String
  field :utm_campaign, type: String

  field :started_at, type: Time
end
