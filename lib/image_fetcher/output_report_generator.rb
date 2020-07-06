# frozen_string_literal: true

module ImageFetcher
  class OutputReportGenerator
    def self.call(*args)
      new(*args).call
    end

    def initialize(results)
      @results = results
    end

    def call
      successful, failed = results.partition(&:success)

      <<~REPORT
        Total number of unique urls: #{results.count},
        Successfully downloaded: #{successful.count},
        Failures: #{failed.count}
      REPORT
    end

    private

    attr_reader :results
  end
end
