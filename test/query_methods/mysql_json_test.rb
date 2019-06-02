require_relative "../test_helper"

class MysqlJsonEvent < MysqlBase
  serialize :properties, JSON if connection.send(:mariadb?)
end

class MysqlJsonTest < Minitest::Test
  include QueryMethodsTest

  def model
    MysqlJsonEvent
  end
end
