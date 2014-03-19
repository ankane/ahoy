module Ahoy
  class Engine < ::Rails::Engine
    isolate_namespace Ahoy

    initializer "ahoy" do |app|
      Ahoy.visit_model ||= Visit
    end

  end
end
