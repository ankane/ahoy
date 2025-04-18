require_relative "query_methods_helper"

class MysqlJsonEvent < MysqlBase
  if connection.send(:mariadb?)
    serialize :properties, coder: JSON
  end
end

class MysqlJsonTest < Minitest::Test
  include QueryMethodsTest

  def model
    MysqlJsonEvent
  end
end
