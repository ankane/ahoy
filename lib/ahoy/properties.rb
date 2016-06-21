module Ahoy
  module Properties
    extend ActiveSupport::Concern

    module ClassMethods
      def where_properties(properties)
        relation = self
        column_type = columns_hash["properties"].type
        case column_type
        when :jsonb, :json
          properties.each do |k, v|
            relation = relation.where("properties ->> ? = ?", k, v)
          end
        else
          properties.each do |k, v|
            # not 100%, but will do
            relation = relation.where("properties LIKE ?", "%#{{k => v}.to_json.sub(/\A\{/, "").sub(/\}\z/, "")}%")
          end
        end
        relation
      end
    end
  end
end
