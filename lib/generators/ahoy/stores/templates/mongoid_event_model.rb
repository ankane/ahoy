class Ahoy::Event
  include Mongoid::Document

  # associations
  belongs_to :user

  # fields
  field :visit_id, type: BSON::Binary
  field :name, type: String
  field :properties, type: Hash
  field :time, type: Time
end
