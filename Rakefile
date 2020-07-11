require "bundler/gem_tasks"
require "rake/testtask"

task default: :test
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/*_test.rb"
  t.warning = false
end

Rake::TestTask.new("test:query_methods") do |t|
  t.libs << "test"
  t.pattern = "test/query_methods/*_test.rb"
  t.warning = false
end
