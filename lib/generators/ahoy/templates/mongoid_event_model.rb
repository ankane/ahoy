class Ahoy::Event
  include Mongoid::Document

  # associations
  belongs_to :visit, index: true
  belongs_to :user, index: true<%= rails5? ? ", optional: true" : nil %>

  # fields
  field :name, type: String
  field :properties, type: Hash
  field :time, type: Time

  index({name: 1, time: 1})
end
