class Ahoy::Event
  include Mongoid::Document

  # associations
  belongs_to :visit
  belongs_to :user<%= rails5? ? ", optional: true" : nil %>

  # fields
  field :name, type: String
  field :properties, type: Hash
  field :time, type: Time

  index({visit_id: 1, name: 1})
  index({user_id: 1, name: 1})
  index({name: 1, time: 1})
end
