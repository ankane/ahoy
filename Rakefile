require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
  t.warning = false # for mongoid, device_detector, user_agent_parser
end

task default: :test
