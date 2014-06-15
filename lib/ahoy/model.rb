module Ahoy
  module Model

    def ahoy_visit
      class_eval do
        belongs_to :user, polymorphic: true

        def landing_params
          @landing_params ||= begin
            ActiveSupport::HashWithIndifferentAccess.new(Extractors::UtmParameterExtractor.new(landing_page).landing_params)
          end
        end

      end
    end

    def visitable(name = nil, options = {})
      if name.is_a?(Hash)
        name = nil
        options = name
      end
      name ||= :visit
      class_eval do
        belongs_to name, options
        before_create :set_visit
      end
      class_eval %Q{
        def set_visit
          self.#{name} ||= RequestStore.store[:ahoy_controller].try(:send, :current_visit)
        end
      }
    end

  end
end
