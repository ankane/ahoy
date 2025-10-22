require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
  t.warning = false # for bson, mongoid, device_detector, browser
end

task default: :test
