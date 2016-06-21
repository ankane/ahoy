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
            relation = relation.where("properties ->> ? = ?", k.to_s, v.to_s)
          end
        else
          adapter_name = connection.adapter_name.downcase
          case adapter_name
          when /postgres/
            properties.each do |k, v|
              relation = relation.where("properties SIMILAR TO ?", "%[{,]#{{k.to_s => v}.to_json.sub(/\A\{/, "").sub(/\}\z/, "")}[,}]%")
            end
          when /mysql/
            properties.each do |k, v|
              relation = relation.where("properties REGEXP ?", "[{,]#{{k.to_s => v}.to_json.sub(/\A\{/, "").sub(/\}\z/, "")}[,}]")
            end
          else
            raise "Adapter not supported: #{adapter_name}"
          end
        end
        relation
      end
    end
  end
end
