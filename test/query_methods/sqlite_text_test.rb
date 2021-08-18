require_relative "query_methods_helper"

class SqliteTextEvent < SqliteBase
  self.table_name = "text_events"
  serialize :properties, JSON
end

class SqliteTextTest < Minitest::Test
  include QueryMethodsTest

  def model
    SqliteTextEvent
  end
end
