module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search(query, fields = [])
      return all if query.blank?

      conditions = []
      values = {}

      Array(fields).each do |field|
        column_type = columns_hash[field.to_s].type

        if column_type == :integer
          conditions << "CAST(#{table_name}.#{field} AS TEXT) ILIKE :query"
        else
          conditions << "#{table_name}.#{field} ILIKE :query"
        end
      end

      query_string = conditions.join(" OR ")
      values[:query] = "%#{query}%"

      where(query_string, values).distinct
    end
  end
end
