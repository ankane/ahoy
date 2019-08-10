require "public_suffix"

module Ahoy
  class Attribution
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def generate
      referrer = data[:referrer]
      landing_params = Rack::Utils.parse_nested_query(URI.parse(data[:landing_page]).query) rescue {}

      if data[:utm_medium] == "email"
        channel = "Email"
        source = data[:utm_source]
      elsif data[:utm_source]
        channel = "Tagged"
        source = data[:utm_source]
      elsif landing_params["ref"]
        channel = "Tagged"
        source = landing_params["ref"]
      elsif landing_params["fbclid"]
        channel = "Social"
        source = "Facebook"
      elsif landing_params["mc_cid"]
        # mailchimp
        channel = "Email"
      elsif referrer
        uri = URI.parse(referrer) rescue nil
        if uri
          if uri.scheme == "android-app"
            case uri.hostname
            when "com.google.android.gm"
              channel = "Email"
            when "com.google.android.googlequicksearchbox"
              source = "Google"
            when "m.facebook.com"
              source = "Facebook"
            when "com.Slack"
              source = "Slack"
              channel = "Other"
            else
              channel = "Other"
            end
          elsif uri.hostname == "mail.google.com"
            channel = "Email"
          else
            domain = PublicSuffix.domain(uri.hostname)

            source =
              case domain
              when /google\./
                "Google"
              when "instagram.com"
                "Instagram"
              when "facebook.com"
                "Facebook"
              when "bing.com"
                "Bing"
              when "duckduckgo.com"
                "DuckDuckGo"
              when "t.co", "twitter.com"
                "Twitter"
              when "yahoo.com"
                "Yahoo"
              when "pinterest.com"
                "Pinterest"
              when "yandex.ru"
                "Yandex"
              when "linkedin.com"
                "LinkedIn"
              when "baidu.com"
                "Baidu"
              when "reddit.com"
                "Reddit"
              else
                domain
              end
          end

          channel ||=
            case source
            when "Google", "Bing", "Yahoo", "Yandex", "DuckDuckGo", "Baidu"
              "Search"
            when "Facebook", "Twitter", "Instagram", "Pinterest", "LinkedIn", "Reddit"
              "Social"
            else
              "Site"
            end

        else
          channel = "Other"
        end
      else
        channel = "Direct"
      end

      props = {channel: channel}
      props[:source] = source.first(255) if source
      props
    end
  end
end
