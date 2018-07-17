module Ahoy
  module Model
    def visitable(name = :visit, **options)
      class_eval do
        safe_options = options.dup
        safe_options[:optional] = true if Rails::VERSION::MAJOR >= 5
        belongs_to(name, class_name: "Ahoy::Visit", **safe_options)
        before_create :set_ahoy_visit
      end
      class_eval %{
        def set_ahoy_visit
          self.#{name} ||= Thread.current[:ahoy].try(:visit_or_create)
        end
      }
    end
  end
end
