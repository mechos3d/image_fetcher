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
      urls.each do |url|
        ImageFetchWorker.call(url: url, output_directory: output_directory)
      end
    end

    private

    def create_directory
      FileUtils.mkdir_p(output_directory)
    end

    attr_reader :urls, :output_directory
  end
end
