module FullTableScanMatchers

  # Configuration for the FullTableScanMatchers module.
  class Configuration
    attr_accessor :ignores, :adapter, :log_backtrace, :backtrace_filter, :eager

    def initialize
      @ignores          = []
      @adapter          = DBAdapters::MySql
      @log_backtrace    = false
      @backtrace_filter = Proc.new { |backtrace| backtrace }
      @eager            = false
    end
  end
end
