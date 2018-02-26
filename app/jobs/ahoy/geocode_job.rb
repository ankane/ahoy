# for smooth update from Ahoy 1 -> 2
module Ahoy
  class GeocodeJob < ActiveJob::Base
    queue_as { Ahoy.job_queue }

    def perform(visit)
      Ahoy::GeocodeV2Job.perform_now(visit.visit_token, visit.ip)
    end
  end
end
