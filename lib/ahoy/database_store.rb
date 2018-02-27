module Ahoy
  class DatabaseStore < BaseStore
    def track_visit(data)
      @visit = visit_model.create!(slice_data(visit_model, data))
    rescue => e
      raise e unless unique_exception?(e)
      @visit = nil
    end

    def track_event(data)
      visit = visit_or_create
      if visit
        event = event_model.new(slice_data(event_model, data))
        event.visit = visit
        begin
          event.save!
        rescue => e
          raise e unless unique_exception?(e)
        end
      else
        Rails.logger.warn "[ahoy] Event excluded since visit not created: #{data[:visit_token]}"
      end
    end

    def geocode(data)
      data = slice_data(visit_model, data.except(:visit_token))
      if defined?(Mongoid::Document) && visit_model < Mongoid::Document
        # upsert since visit might not be found due to eventual consistency
        visit_model.where(visit_token: ahoy.visit_token).find_one_and_update({"$set": data}, {upsert: true})
      elsif visit
        visit.update_attributes(data)
      else
        Rails.logger.warn "[ahoy] Visit for geocode not found: #{data[:visit_token]}"
      end
    end

    def authenticate(_)
      if visit && visit.respond_to?(:user) && !visit.user
        begin
          visit.user = user
          visit.save!
        rescue ActiveRecord::AssociationTypeMismatch
          # do nothing
        end
      end
    end

    def visit
      @visit ||= visit_model.where(visit_token: ahoy.visit_token).first if ahoy.visit_token
    end

    # if we don't have a visit, let's try to create one first
    def visit_or_create
      ahoy.track_visit unless visit
      visit
    end

    protected

    def visit_model
      ::Ahoy::Visit
    end

    def event_model
      ::Ahoy::Event
    end

    def slice_data(model, data)
      column_names = model.try(:column_names) || model.attribute_names
      data.slice(*column_names.map(&:to_sym)).select { |_, v| v }
    end

    def unique_exception?(e)
      return true if defined?(ActiveRecord::RecordNotUnique) && e.is_a?(ActiveRecord::RecordNotUnique)
      return true if defined?(PG::UniqueViolation) && e.is_a?(PG::UniqueViolation)
      return true if defined?(Mongo::Error::OperationFailure) && e.is_a?(Mongo::Error::OperationFailure) && e.message.include?("duplicate key error")
      false
    end
  end
end
