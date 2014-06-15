module Ahoy
  module Extractors
    class UtmParameterExtractor

      def initialize(landing_page)
        @landing_page = landing_page
      end

      def landing_params
        @landing_params ||= begin
          landing_uri = Addressable::URI.parse(@landing_page) rescue nil
          (landing_uri && landing_uri.query_values) || {}
        end
      end

      %w[utm_source utm_medium utm_term utm_content utm_campaign].each do |name|
        define_method name do
          landing_params[name]
        end
      end

    end
  end
end
