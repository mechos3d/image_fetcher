# frozen_string_literal: true

require_relative './requires.rb'

module ImageFetcher
  ENVIRONMENT = (ENV['APP_ENV'] || 'development').to_sym unless defined?(ImageFetcher::ENVIRONMENT)
end
