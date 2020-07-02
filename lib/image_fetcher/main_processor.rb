# frozen_string_literal: true

module ImageFetcher
  class MainProcessor

    def initialize(urls:, output_directory:)
      @urls = urls
      @output_directory = output_directory
    end

    def call
    end

    private

    attr_reader :urls, :output_directory
  end
end
