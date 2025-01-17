require 'ostruct'

module FullTableScanMatchers
  module DBAdapters
    module MySql
      class LazyExplainResult
        attr_accessor :sql_statement, :structs, :backtrace, :tables

        def initialize(sql_statement, backtrace: nil, tables: nil)
          @sql_statement = sql_statement
          @backtrace     = backtrace
          @tables        = tables
        end

        def force
          explained_result
        end

        def full_table_scan?
          offending_structs.any?
        end

        def structs
          @structs ||= as_hashes.map { |hash| OpenStruct.new hash }
        end

        def to_s
          [
            "SQL:  #{sql_statement}",
            structs.map do |struct|
              (offending_structs.include?(struct) ? "FAIL: " : "INFO: ") +
              struct.to_h.map { |k, v| "#{k}: #{v}" }.join(", ")
            end,
            (backtrace.present? ? "BACKTRACE: #{backtrace}" : nil)
          ].flatten.compact.join "\n"
        end

      private

        def offending_structs
          structs
            .reject  { |struct| struct.table == "NULL" }
            .reject  { |struct| struct.table.match?(/<subquery\d+>/) if FullTableScanMatchers.configuration.ignore_materialized }
            .select  { |struct| tables.nil? || Array(tables).map(&:to_s).include?(struct.table) }
            .select  { |struct| struct.key == "NULL" && struct.possible_keys == "NULL" }
        end

        def as_hashes
          keys = explain_rows.shift.map(&:downcase)
          explain_rows.map { |values| Hash[keys.zip(values)].symbolize_keys! }
        end

        def explain_rows
          @explain_rows ||= explained_result
            .reject { |row| row =~ /^\s*\+/ }        # Reject table frames, like: +----+-------------+
            .reject { |row| row =~ / rows? in set/ } # Reject "1 row in set" type things after result
            .map    { |row| row.split("|").map(&:strip).reject &:blank? }
        end

        def explained_result
          @explained_result ||= ActiveRecord::Base.connection.explain(sql_statement).split("\n")
        end
      end
    end
  end
end
