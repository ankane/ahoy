module Ahoy
  class Visit < ActiveRecord::Base
    belongs_to :user, polymorphic: true
  end
end
