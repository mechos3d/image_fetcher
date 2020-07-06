# frozen_string_literal: true

module ImageFetcher
  class Logger
    # NOTE: this is accessed from multiple threads so the operations here must be atomic
    # or else need to add a Mutex:
    def self.log(message)
      return if ::ImageFetcher::ENVIRONMENT == :test

      STDOUT.write(message + "\n")
    end

    def self.log_error(message)
      return if ::ImageFetcher::ENVIRONMENT == :test

      STDERR.write("ERROR: #{message}\n")
    end
  end
end
