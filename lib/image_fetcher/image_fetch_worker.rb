# frozen_string_literal: true

module ImageFetcher
  class ImageFetchWorker
    def initialize(url:, output_directory:)
      @url = url
      @output_directory = output_directory
    end

    def call
    end

    private

    attr_reader :url, :output_directory

  end
end
