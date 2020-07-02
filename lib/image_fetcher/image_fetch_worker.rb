# frozen_string_literal: true

require 'faraday'

module ImageFetcher
  class ImageFetchWorker
    def initialize(url:, output_directory:)
      @url              = url
      @output_directory = output_directory
    end

    def call
      conn = Faraday.new(url, request: { timeout: 5 })
      response = conn.get
      if response.success?
        SaveFile.call(url: url,
                      output_directory: output_directory,
                      contents: response.body)
      end
    end

    private

    attr_reader :url, :output_directory

  end
end
