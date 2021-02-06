require_relative "query_methods_helper"

class MysqlJsonEvent < MysqlBase
  serialize :properties, JSON if connection.send(:mariadb?)
end

class MysqlJsonTest < Minitest::Test
  include QueryMethodsTest

  def model
    MysqlJsonEvent
  end
end
