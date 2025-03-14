require_relative "../test_helper"

case ENV["ADAPTER"]
when "mysql2", "trilogy"
  require_relative "../support/mysql"
when "postgresql"
  require_relative "../support/postgresql"
when "mongoid"
  require_relative "../support/mongoid"
else
  require_relative "../support/sqlite"
end

require_relative "../support/query_methods_test"
