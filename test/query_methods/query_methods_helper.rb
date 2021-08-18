require_relative "../test_helper"

adapter = ENV["ADAPTER"]
abort "No adapter specified" unless adapter

puts "Using #{adapter}"
case adapter
when "mysql"
  require_relative "../support/mysql"
when "postgresql"
  require_relative "../support/postgresql"
when "mongoid"
  require_relative "../support/mongoid"
else
  require_relative "../support/sqlite"
end

require_relative "../support/query_methods_test"
