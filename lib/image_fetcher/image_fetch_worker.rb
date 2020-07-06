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
      return invalid_url if invalid_url

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
    rescue URI::InvalidURIError => e
      invalid_url_result
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

    # NOTE: the protocol in the url is required for now.
    #       I have to parse the url and not rely on 'URI::InvalidURIError' because
    #       for urls like 'ttps://foo.com' it doesn't raise URI::InvalidURIError,
    #       NoMethodError is raised for such urls instead.
    # TODO: we can add https (and http as a fallback) if user didn't provide protocol.
    # TODO: Maybe better to use existing solution like
    # https://github.com/perfectline/validates_url/blob/master/lib/validate_url.rb
    # but currently it has ActiveModel as dependency and it's unnecessary here.
    def invalid_url
      parsed = URI.parse(url)
      return if parsed.is_a?(URI::HTTPS) || parsed.is_a?(URI::HTTP)

      invalid_url_result
    end

    def invalid_url_result
      Result.new(false, url, nil, ErrorCodes.invalid_url)
    end
  end
end
