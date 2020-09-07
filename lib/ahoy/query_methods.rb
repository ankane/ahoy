module Ahoy
  module QueryMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def where_event(name, properties = {})
        where(name: name).where_props(properties)
      end

      def where_props(properties)
        relation = self
        if respond_to?(:columns_hash)
          column_type = columns_hash["properties"].type
          adapter_name = connection.adapter_name.downcase
        else
          adapter_name = "mongoid"
        end
        case adapter_name
        when "mongoid"
          relation = where(Hash[properties.map { |k, v| ["properties.#{k}", v] }])
        when /mysql/
          if column_type == :json
            properties.each do |k, v|
              if v.nil?
                v = "null"
              elsif v == true
                v = "true"
              end

              relation = relation.where("JSON_UNQUOTE(properties -> ?) = ?", "$.#{k}", v.as_json)
            end
          else
            properties.each do |k, v|
              relation = relation.where("properties REGEXP ?", "[{,]#{{k.to_s => v}.to_json.sub(/\A\{/, "").sub(/\}\z/, "").gsub("+", "\\\\+")}[,}]")
            end
          end
        when /postgres|postgis/
          if column_type == :jsonb
            relation = relation.where("properties @> ?", properties.to_json)
          elsif column_type == :json
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
              relation = relation.where("properties SIMILAR TO ?", "%[{,]#{{k.to_s => v}.to_json.sub(/\A\{/, "").sub(/\}\z/, "").gsub("+", "\\\\+")}[,}]%")
            end
          end
        else
          raise "Adapter not supported: #{adapter_name}"
        end
        relation
      end
      alias_method :where_properties, :where_props

      def group_prop(name)
        relation = self
        if respond_to?(:columns_hash)
          column_type = columns_hash["properties"].type
          adapter_name = connection.adapter_name.downcase
        else
          adapter_name = "mongoid"
        end
        case adapter_name
        when "mongoid"
          raise "Adapter not supported: #{adapter_name}"
        when /mysql/
          raise "MySQL and MariaDB not supported yet"
          # quoted_name = connection.quote("$.#{name}")
          # if connection.try(:mariadb?)
          #   relation = relation.group("JSON_VALUE(properties, #{connection.quote("$.#{name}")})")
          # elsif column_type == :json
          #   relation = relation.group("properties -> #{quoted_name}")
          # else
          #   relation = relation.group("CAST(properties AS JSON) -> #{quoted_name}")
          # end
        when /postgres|postgis/
          quoted_name = connection.quote(name)

          # convert to jsonb to fix
          # could not identify an equality operator for type json
          # and for text columns
          cast = [:jsonb, :hstore].include?(column_type) ? "" : "::jsonb"

          relation = relation.group("properties#{cast} -> #{quoted_name}")
        else
          raise "Adapter not supported: #{adapter_name}"
        end
        relation
      end
    end
  end
end

# backward compatibility
Ahoy::Properties = Ahoy::QueryMethods
