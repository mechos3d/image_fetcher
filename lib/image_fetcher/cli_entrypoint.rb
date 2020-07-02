# frozen_string_literal: true

module ImageFetcher
  class CliEntrypoint

    def initialize(input: ARGV, output: STDOUT, err_out: STDERR)
      @input     = input
      @output    = output
      @error_out = error_out
    end

    def call
    end

    private

    attr_reader  :input, :output, :error_out

  end
end
