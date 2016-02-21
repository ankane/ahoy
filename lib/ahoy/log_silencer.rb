module Ahoy
  module LogSilencer
    PATH_INFO = "PATH_INFO".freeze
    AHOY_PREFIX = "/ahoy/".freeze

    def call(env)
      if env[PATH_INFO].start_with?(AHOY_PREFIX) && logger.respond_to?(:silence_logger)
        logger.silence_logger do
          super
        end
      else
        super
      end
    end
  end
end
