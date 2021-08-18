require_relative "../test_helper"

# run setup / migrations
require_relative "../support/mysql"
require_relative "../support/postgresql"
require_relative "../support/mongoid"
require_relative "../support/sqlite"

# restore connection
ActiveRecord::Base.establish_connection(:test)

require_relative "../support/query_methods_test"
