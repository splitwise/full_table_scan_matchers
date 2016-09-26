require 'ostruct'

module FullTableScanMatchers
  module DBAdapters
    module MySql
      class ExplainResult
        attr_accessor :sql_statement, :structs

        def initialize(sql_statement)
          @sql_statement = sql_statement
        end

        # TODO - Make this much more clever:
        def full_table_scan?
          structs.any? { |struct| struct.key == "NULL" && struct.possible_keys == "NULL" }
        end

        def structs
          @structs ||= as_hashes.map { |hash| OpenStruct.new hash }
        end

      private

        def as_hashes
          keys = explain_rows.shift.map(&:downcase)
          explain_rows.map { |values| Hash[keys.zip(values)].symbolize_keys! }
        end

        def explain_rows
          @explain_rows ||= explained_result
            .reject { |row| row =~ /^\s+\+/ }
            .map    { |row| row.split("|").map(&:strip).reject &:blank? }
        end

        def explained_result
          @explained_result ||= ActiveRecord::Base.connection.explain(sql_statement).split("\n")
        end
      end
    end
  end
end
