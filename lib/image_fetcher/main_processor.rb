# frozen_string_literal: true

module ImageFetcher
  class MainProcessor
    def self.call(**args)
      new(**args).call
    end

    def initialize(urls:, output_directory:)
      # TODO: add specs on this class' behavior when urls are not uniq:
      @urls = urls.uniq
      @output_directory = output_directory
    end

    def call
      create_directory

      pool = Concurrent::ThreadPoolExecutor.new(
         min_threads: 5,
         max_threads: 50,
         max_queue: 0
      )

      futures = urls.map do |url|
        Concurrent::Future.new(executor: pool) do
          ImageFetchWorker.call(url: url, output_directory: output_directory)
        end
      end
      futures.each { |future| future.execute }
      futures.map { |future| future.value }
    end

    private

    def create_directory
      # TODO: check for FS permissions here.
      # (what if the directory exists but current user doesn't have permissions for it)
      FileUtils.mkdir_p(output_directory)
    end

    attr_reader :urls, :output_directory
  end
end
