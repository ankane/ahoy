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
          column = column_type == :json || connection.try(:mariadb?) ? "properties" : "CAST(properties AS JSON)"
          properties.each do |k, v|
            if v.nil?
              v = "null"
            elsif v == true
              v = "true"
            end

            relation = relation.where("JSON_UNQUOTE(JSON_EXTRACT(#{column}, ?)) = ?", "$.#{k}", v.as_json)
          end
        when /postgres|postgis/
          case column_type
          when :jsonb
            relation = relation.where("properties @> ?", properties.to_json)
          when :hstore
            properties.each do |k, v|
              relation =
                if v.nil?
                  relation.where("properties -> ? IS NULL", k.to_s)
                else
                  relation.where("properties -> ? = ?", k.to_s, v.to_s)
                end
            end
          else
            relation = relation.where("properties::jsonb @> ?", properties.to_json)
          end
        else
          raise "Adapter not supported: #{adapter_name}"
        end
        relation
      end
      alias_method :where_properties, :where_props

      def group_prop(*props)
        # like with group
        props.flatten!

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
          column = column_type == :json || connection.try(:mariadb?) ? "properties" : "CAST(properties AS JSON)"
          props.each do |prop|
            quoted_prop = connection.quote("$.#{prop}")
            relation = relation.group("JSON_UNQUOTE(JSON_EXTRACT(#{column}, #{quoted_prop}))")
          end
        when /postgres|postgis/
          # convert to jsonb to fix
          # could not identify an equality operator for type json
          # and for text columns
          cast = [:jsonb, :hstore].include?(column_type) ? "" : "::jsonb"

          props.each do |prop|
            quoted_prop = connection.quote(prop)
            relation = relation.group("properties#{cast} -> #{quoted_prop}")
          end
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
