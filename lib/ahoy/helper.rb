module Ahoy
  module Helper
    def amp_analytics options={}
      content_tag 'amp-analytics', options do
        content_tag 'script', type: 'application/json' do
          JSON::dump({
            requests: {
              pageview: Ahoy::Engine.routes.url_helpers.visits_url(
                protocol: '//',
                host: request.host_with_port,
                visit_token: ahoy.visit_token,
                visitor_token: ahoy.visitor_token,
                screen_width: 'SCREEN_WIDTH',
                screen_height: 'SCREEN_HEIGHT',
                platform: 'Web',
                landing_page: 'AMPDOC_URL',
                referrer: 'DOCUMENT_REFERRER',
                random: 'RANDOM'
              )
            },
            triggers: {
              trackPageview: {
                on: 'ini-load',
                request: 'pageview'
              }
            },
            transport: {
              beacon: true,
              xhrpost: true,
              image: false
            }
          }).html_safe
        end
      end
    end
  end
end
