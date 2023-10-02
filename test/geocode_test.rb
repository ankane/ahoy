require_relative "test_helper"

module Geocoder
  def self.search(ip)
    require "ostruct"

    [OpenStruct.new(
      country: "Test"
    )]
  end
end

class GeocodeTest < ActionDispatch::IntegrationTest
  def test_geocode_true
    with_options(geocode: true) do
      assert_enqueued_with(job: Ahoy::GeocodeV2Job, queue: "ahoy") do
        get products_url
      end
      perform_enqueued_jobs
      assert_equal "Test", Ahoy::Visit.last.country
    end
  end

  def test_geocode_true_cookies_none
    with_options(geocode: true, cookies: :none) do
      assert_enqueued_with(job: Ahoy::GeocodeV2Job, queue: "ahoy") do
        get products_url
      end
      perform_enqueued_jobs
      assert_equal "Test", Ahoy::Visit.last.country
    end
  end

  def test_geocode_false
    with_options(geocode: false) do
      get products_url
      assert_equal 0, enqueued_jobs.size
    end
  end

  def test_geocode_default
    get products_url
    assert_equal 0, enqueued_jobs.size
  end

  def test_job_queue
    with_options(geocode: true, job_queue: :low_priority) do
      assert_enqueued_with(job: Ahoy::GeocodeV2Job, queue: "low_priority") do
        get products_url
      end
    end
  end
end
