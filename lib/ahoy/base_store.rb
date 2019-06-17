module Ahoy
  class BaseStore
    attr_writer :user

    def initialize(options)
      @options = options
    end

    def track_visit(data)
    end

    def track_event(data)
    end

    def geocode(data)
    end

    def authenticate(data)
    end

    def visit
    end

    def user
      @user ||= @options[:user_resolver].try(:call)
    end

    def exclude?
      (!Ahoy.track_bots && bot?) || exclude_by_method?
    end

    def generate_id
      Ahoy.token_generator.call
    end

    def visit_or_create
      visit
    end

    protected

    def bot?
      return @bot if defined?(@bot)
      return false unless params["user_agent"]

      @bot = begin
        if Ahoy.user_agent_parser != :device_detector
          # no need to throw friendly error if browser isn't defined
          # since will error in visit_properties
          Browser.new(params["user_agent"]).bot?
        elsif Ahoy.bot_detection_version == 2
          detector = DeviceDetector.new(params["user_agent"])
          detector.bot? || (detector.device_type.nil? && detector.os_name.nil?)
        else
          false
        end
      end
    end

    def exclude_by_method?
      @options[:exclude_method_resolver].try(:call)
    end

    def params
      @params ||= @options.fetch(:params, {})
    end

    def ahoy
      @ahoy ||= @options[:ahoy]
    end
  end
end
