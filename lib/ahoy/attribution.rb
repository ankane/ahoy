require "public_suffix"

module Ahoy
  class Attribution
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def generate
      referrer = data[:referrer]

      if data[:utm_medium] == "email"
        channel = "Email"
        source = data[:utm_campaign] || data[:utm_source]
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
