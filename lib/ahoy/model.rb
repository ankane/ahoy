module Ahoy
  module Model
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
      class_eval %{
        def set_visit
          self.#{name} ||= RequestStore.store[:ahoy].try(:visit)
        end
      }
    end

    # deprecated

    def ahoy_visit
      class_eval do
        warn "[DEPRECATION] ahoy_visit is deprecated"

        belongs_to :user, polymorphic: true

        def landing_params
          @landing_params ||= begin
            warn "[DEPRECATION] landing_params is deprecated"
            Deckhands::UtmParameterDeckhand.new(landing_page).landing_params
          end
        end
      end
    end
  end
end
