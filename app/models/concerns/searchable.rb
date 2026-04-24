# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search(query, fields = [])
      return all if query.blank?

      pattern = "%#{sanitize_sql_like(query.to_s)}%"
      conditions = Array(fields).map { |field| search_condition(field, pattern) }
      where(conditions.reduce(:or)).distinct
    end

    private

    def search_condition(field, pattern)
      col = arel_table[field]
      return col.matches(pattern) unless columns_hash[field.to_s].type == :integer

      Arel::Nodes::NamedFunction
        .new('CAST', [Arel::Nodes::As.new(col, Arel::Nodes::SqlLiteral.new('TEXT'))])
        .matches(pattern)
    end
  end
end
