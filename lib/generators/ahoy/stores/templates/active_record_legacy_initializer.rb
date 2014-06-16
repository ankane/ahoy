class Ahoy::Store < Ahoy::Stores::ActiveRecordLegacyStore
  # code generated to assist with the migration
  # if you do not use a method, delete it

  # Ahoy.user_method replacement
  # def user
  #   controller.true_user
  # end

  # Ahoy.track_bots and Ahoy.exclude_method replacement
  # def exclude?
  #   bot? || request.ip == "1.1.1.1"
  # end

  # Ahoy.visit_model replacement
  # def visit_model
  #   CustomVisit
  # end

  # Custom subscriber replacement
  # Not needed if ActiveRecord subscriber used
  # def track_event(name, properties, options)
  #   # track method goes here
  # end

  # Ahoy::Subscribers::ActiveRecord.new(model: CustomEvent) replacement
  # def event_model
  #   CustomEvent
  # end

end
