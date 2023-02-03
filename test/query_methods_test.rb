require_relative "test_helper"

case ENV["ADAPTER"]
when "mysql2"
  require_relative "query_methods/mysql_json_test"
  require_relative "query_methods/mysql_text_test"
when "postgresql"
  require_relative "query_methods/postgresql_hstore_test"
  require_relative "query_methods/postgresql_json_test"
  require_relative "query_methods/postgresql_jsonb_test"
when "mongoid"
  require_relative "query_methods/mongoid_test"
else
  require_relative "query_methods/sqlite_text_test"
end
