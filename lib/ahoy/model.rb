module Ahoy
  module Model

    def ahoy_visit
      class_eval do

        belongs_to :user, polymorphic: true

        before_create :set_traffic_source
        before_create :set_utm_parameters
        before_create :set_technology
        before_create :set_location

        def set_traffic_source
          referring_domain = Addressable::URI.parse(referrer).host.first(255) rescue nil
          self.referring_domain = referring_domain if respond_to?(:referring_domain=)
          # performance hack for referer-parser
          search_keyword = Ahoy.referrer_parser.parse(referrer)[1].first(255) rescue nil
          self.search_keyword = search_keyword.presence if respond_to?(:search_keyword=)
          true
        end

        def set_utm_parameters
          %w[utm_source utm_medium utm_term utm_content utm_campaign].each do |name|
            self[name] = landing_params[name] if respond_to?(:"#{name}=")
          end
          true
        end

        def set_technology
          if respond_to?(:user_agent)
            agent = Ahoy.user_agent_parser.parse(user_agent)

            self.browser = agent.name if respond_to?(:browser=)
            self.os = agent.os.name if respond_to?(:os=)

            browser = Browser.new(ua: user_agent)
            self.device_type =
              if browser.tv?
                "TV"
              elsif browser.console?
                "Console"
              elsif browser.tablet?
                "Tablet"
              elsif browser.mobile?
                "Mobile"
              else
                "Desktop"
              end if respond_to?(:device_type=)
          end
          true
        end

        def set_location
          if respond_to?(:ip) and [:country=, :region=, :city=].any?{|method| respond_to?(method) }
            location =
              begin
                Geocoder.search(ip).first
              rescue => e
                $stderr.puts e.message
                nil
              end

            if location
              self.country = location.country.presence if respond_to?(:country=)
              self.region = location.state.presence if respond_to?(:region=)
              self.city = location.city.presence if respond_to?(:city=)
            end
          end
          true
        end

        def landing_params
          @landing_params ||= begin
            landing_uri = Addressable::URI.parse(landing_page) rescue nil
            ActiveSupport::HashWithIndifferentAccess.new((landing_uri && landing_uri.query_values) || {})
          end
        end

      end # end class_eval
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
