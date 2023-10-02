require_relative "test_helper"

module Geocoder
  def self.search(ip)
    require "ostruct"

    [OpenStruct.new(
      country: "Country",
      state: "Region",
      city: "City",
      latitude: 1,
      longitude: 2
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
      visit = Ahoy::Visit.last
      assert_equal "Country", visit.country
      assert_equal "Region", visit.region
      assert_equal "City", visit.city
      assert_equal 1, visit.latitude
      assert_equal 2, visit.longitude
    end
  end

  def test_geocode_true_cookies_none
    with_options(geocode: true, cookies: :none) do
      assert_enqueued_with(job: Ahoy::GeocodeV2Job, queue: "ahoy") do
        get products_url
      end
      perform_enqueued_jobs
      visit = Ahoy::Visit.last
      assert_equal "Country", visit.country
      assert_equal "Region", visit.region
      assert_equal "City", visit.city
      assert_equal 1, visit.latitude
      assert_equal 2, visit.longitude
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
