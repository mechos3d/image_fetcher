# frozen_string_literal: true

module ImageFetcher
  module Utils
    # TODO: need a spec on the 'uniqueness' behavior:
    def self.filename_from_url(url)
      name = url.split('/').last
      [Digest::MD5.hexdigest(url), name].join('__')
    end

    # NOTE: about 'valid_url?' - the protocol in the url is required for now.
    #       We have to parse the url and not rely on 'URI::InvalidURIError' because
    #       for urls like 'ttps://foo.com' it doesn't raise URI::InvalidURIError,
    #       NoMethodError is raised for such urls instead.
    # TODO: we can add https (and http as a fallback) if user didn't provide protocol.
    # TODO: Maybe better to use existing solution like
    # https://github.com/perfectline/validates_url/blob/master/lib/validate_url.rb
    # but currently it has ActiveModel as dependency and it's unnecessary here in my opinion.
    #
    # NOTE: currently this method cannot fully guarantee the URI validity, so there still
    # is a possibilty of raising InvalidURIError while performing the request itself

    # TODO: add specs:
    def self.valid_url?(url)
      parsed = URI.parse(url)
      parsed.is_a?(URI::HTTPS) || parsed.is_a?(URI::HTTP)
    rescue URI::InvalidURIError
      false
    end
  end
end
