require_relative "query_methods_helper"

class MysqlTextEvent < MysqlBase
  serialize :properties, coder: JSON
end

class MysqlTextTest < Minitest::Test
  include QueryMethodsTest

  def model
    MysqlTextEvent
  end
end
