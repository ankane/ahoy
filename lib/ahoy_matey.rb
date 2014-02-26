require "ahoy/version"
require "addressable/uri"
require "browser"
require "geocoder"

module Ahoy
  class Engine < ::Rails::Engine
    isolate_namespace Ahoy
  end
end
