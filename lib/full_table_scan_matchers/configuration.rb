module FullTableScanMatchers

  # Configuration for the FullTableScanMatchers module.
  class Configuration
    attr_accessor :ignores, :adapter, :log_backtrace, :backtrace_filter, :eager, :ignore_materialized

    def initialize
      @ignores              = []
      @adapter              = DBAdapters::MySql
      @log_backtrace        = false
      @backtrace_filter     = Proc.new { |backtrace| backtrace }
      @eager                = false
      @ignore_materialized  = false
    end
  end
end
