require_relative "query_methods_helper"

class SqliteTextEvent < SqliteBase
  self.table_name = "text_events"

  if ActiveRecord::VERSION::STRING.to_f >= 7.1
    serialize :properties, coder: JSON
  else
    serialize :properties, JSON
  end
end

class SqliteTextTest < Minitest::Test
  include QueryMethodsTest

  def model
    SqliteTextEvent
  end
end
