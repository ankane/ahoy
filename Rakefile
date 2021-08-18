require "bundler/gem_tasks"
require "rake/testtask"

task default: :test
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/*_test.rb"
  t.warning = false # for bson, mongoid, device_detector, browser
end

ADAPTERS = %w(postgresql mysql sqlite mongoid)

namespace :test do
  namespace :query_methods do
    ADAPTERS.each do |adapter|
      task("env:#{adapter}") { ENV["ADAPTER"] = adapter }

      Rake::TestTask.new(adapter => "env:#{adapter}") do |t|
        t.description = "Run query method tests for #{adapter}"
        t.libs << "test"
        t.pattern = "test/query_methods/#{adapter}*_test.rb"
        t.warning = false
      end
    end
  end
end

desc "Run query method tests for all adapters"
namespace :test do
  task :query_methods do
    ADAPTERS.each do |adapter|
      Rake::Task["test:query_methods:#{adapter}"].invoke
    end
  end
end
