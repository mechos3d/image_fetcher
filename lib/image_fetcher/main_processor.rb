# frozen_string_literal: true

require 'fileutils'

module ImageFetcher
  class MainProcessor

    def initialize(urls:, output_directory:)
      @urls = urls
      @output_directory = output_directory
    end

    def call
      create_directory
    end

    private

    def create_directory
      FileUtils.mkdir_p(output_directory)
    end

    attr_reader :urls, :output_directory
  end
end
