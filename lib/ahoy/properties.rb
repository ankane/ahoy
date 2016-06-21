module Ahoy
  module Properties
    extend ActiveSupport::Concern

    module ClassMethods
      def where_properties(properties)
        relation = self
        column_type = columns_hash["properties"].type
        adapter_name = connection.adapter_name.downcase
        case adapter_name
        when /mysql/
          if column_type == :json
            properties.each do |k, v|
              if v.nil?
                v = "null"
              elsif v == true
                v = "true"
              end

              relation = relation.where("JSON_UNQUOTE(properties -> ?) = ?", "$.#{k.to_s}", v.as_json)
            end
          else
            properties.each do |k, v|
              relation = relation.where("properties REGEXP ?", "[{,]#{{k.to_s => v}.to_json.sub(/\A\{/, "").sub(/\}\z/, "")}[,}]")
            end
          end
        when /postgres/
          if column_type == :jsonb || column_type == :json
            properties.each do |k, v|
              relation =
                if v.nil?
                  relation.where("properties ->> ? IS NULL", k.to_s)
                else
                  relation.where("properties ->> ? = ?", k.to_s, v.as_json.to_s)
                end
            end
          elsif column_type == :hstore
            properties.each do |k, v|
              relation =
                if v.nil?
                  relation.where("properties -> ? IS NULL", k.to_s)
                else
                  relation.where("properties -> ? = ?", k.to_s, v.to_s)
                end
            end
          else
            properties.each do |k, v|
              relation = relation.where("properties SIMILAR TO ?", "%[{,]#{{k.to_s => v}.to_json.sub(/\A\{/, "").sub(/\}\z/, "")}[,}]%")
            end
          end
        else
          raise "Adapter not supported: #{adapter_name}"
        end
        relation
      end
    end
  end
end
