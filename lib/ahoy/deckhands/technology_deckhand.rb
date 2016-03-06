module Ahoy
  module Deckhands
    class TechnologyDeckhand
      def initialize(user_agent)
        @user_agent = user_agent
      end

      def browser
        agent.name
      end

      def os
        agent.os.name
      end

      def device_type
        @device_type ||= begin
          browser = Browser.new(@user_agent)
          if browser.bot?
            "Bot"
          elsif browser.device.tv?
            "TV"
          elsif browser.device.console?
            "Console"
          elsif browser.device.tablet?
            "Tablet"
          elsif browser.device.mobile?
            "Mobile"
          else
            "Desktop"
          end
        end
      end

      protected

      def agent
        @agent ||= self.class.user_agent_parser.parse(@user_agent)
      end

      # performance
      def self.user_agent_parser
        @user_agent_parser ||= UserAgentParser::Parser.new
      end
    end
  end
end
