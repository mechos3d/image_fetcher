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
      connection_ok, response = make_request

      if connection_ok && response.success?
        return(
          SaveFile.call(url: url,
                        output_directory: output_directory,
                        contents: response.body)
        )
      end

      error_code = connection_ok ? ErrorCodes.fail_response : ErrorCodes.connection_error
      Result.new(false, url, response, error_code)
    rescue StandardError => e
      # TODO: can write to stderr from here but only using a Mutex
      Result.new(false, url, e, ErrorCodes.unhandled_exception)
    end

    private

    attr_reader :url, :output_directory

    def make_request
      conn = Faraday.new(url, request: { timeout: 5 }) do |faraday|
        # NOTE: the default value for follow-redirects limit is 3
        faraday.use ::FaradayMiddleware::FollowRedirects
      end
      [true, conn.get]
    rescue Faraday::SSLError, Faraday::ConnectionFailed, Faraday::TimeoutError => e
      [false, e]
    end
  end
end
