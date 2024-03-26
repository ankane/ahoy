require_relative "query_methods_helper"

class MysqlJsonEvent < MysqlBase
  if connection.send(:mariadb?)
    if ActiveRecord::VERSION::STRING.to_f >= 7.1
      serialize :properties, coder: JSON
    else
      serialize :properties, JSON
    end
  end
end

class MysqlJsonTest < Minitest::Test
  include QueryMethodsTest

  def model
    MysqlJsonEvent
  end
end
