# frozen_string_literal: true

module ImageFetcher
  class ImageFetchWorker
    Result = Struct.new(:success, :url, :details, :error_code)

    def self.call(**args)
      new(**args).call
    end

    def initialize(url:, output_directory:)
      @url              = url
      @output_directory = output_directory
    end

    def call
      return invalid_url_result unless Utils.valid_url?(url)

      process
    rescue URI::InvalidURIError
      # NOTE: See comments on the 'Utils.valid_url?' for more info.
      invalid_url_result
    rescue StandardError => e
      Logger.log_error("url: #{url}; #{e.message}")
      Result.new(false, url, e, ErrorCodes.unhandled_exception)
    end

    private

    attr_reader :url, :output_directory

    def process
      connection_ok, response = make_request
      return(Result.new(false, url, response, ErrorCodes.connection_error)) unless connection_ok

      if response.success?
        SaveFile.call(url: url,
                      output_directory: output_directory,
                      contents: response.body)
      else
        Logger.log_error("url: #{url}; server resonded with: #{response.status}")
        Result.new(false, url, response, ErrorCodes.fail_response)
      end
    end

    def make_request
      conn = Faraday.new(url, request: { timeout: 5 })
      [true, conn.get]
    rescue *connection_exceptions => e
      # TODO: of course the user needs to see better formatted error message
      # not the names of Faraday exception classes:
      Logger.log_error("url: #{url}; connection error: #{e.class}")
      [false, e]
    end

    def connection_exceptions
      [Faraday::SSLError,
       Faraday::ConnectionFailed,
       Faraday::TimeoutError]
    end

    def invalid_url_result
      Logger.log_error("Invalid url: #{url}")
      Result.new(false, url, nil, ErrorCodes.invalid_url)
    end

    def error_code(connection_ok)
      connection_ok ? ErrorCodes.fail_response : ErrorCodes.connection_error
    end
  end
end
