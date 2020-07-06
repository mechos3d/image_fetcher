# frozen_string_literal: true

module ImageFetcher
  class MainProcessor
    def self.call(**args)
      new(**args).call
    end

    def initialize(urls:, output_directory:)
      @urls             = urls.uniq
      @output_directory = output_directory
    end

    def call
      create_directory

      futures = urls.map do |url|
        Concurrent::Future.new(executor: thread_pool) do
          ImageFetchWorker.call(url: url, output_directory: output_directory)
        end
      end

      futures.each(&:execute)
      futures.each do |future|
        # NOTE: in case of some unhandled exception that occured inside a 'Future' -
        # it will have 'nil' as a '.value' and an instance of Error as a '.reason':
        (error = future.reason) && Logger.log_error(error.to_s)
      end
      futures.map(&:value)
    end

    private

    def thread_pool
      # TODO: make thread_pool settings configurable with flags from command-line:
      Concurrent::ThreadPoolExecutor.new(
        min_threads: 5,
        max_threads: 50,
        max_queue: 0
      )
    end

    def create_directory
      # TODO: move the directory creation to 'cli_entrypoint',
      # rescue Errno::EPERM (if current user doesn't have permissions for this operation)
      # and print message to STDERR.
      FileUtils.mkdir_p(output_directory)
    end

    attr_reader :urls, :output_directory
  end
end
