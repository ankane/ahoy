require_relative "query_methods_helper"

class MysqlTextEvent < MysqlBase
  if ActiveRecord::VERSION::STRING.to_f >= 7.1
    serialize :properties, coder: JSON
  else
    serialize :properties, JSON
  end
end

class MysqlTextTest < Minitest::Test
  include QueryMethodsTest

  def model
    MysqlTextEvent
  end
end
