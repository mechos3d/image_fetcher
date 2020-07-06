# frozen_string_literal: true

module ImageFetcher
  class ImageFetchWorker
    class ErrorCodes
      CODES = [:fail_response, :connection_error, :file_already_exists,
               :unhandled_exception, :invalid_url].freeze
      private_constant :CODES

      class << self
        CODES.each do |code_symbol|
          define_method(code_symbol) { code_symbol }
        end
      end
    end
  end
end
