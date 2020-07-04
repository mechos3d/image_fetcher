# frozen_string_literal: true

require_relative './requires.rb'

# TODO: rename the application.
# Why is it 'ImageFetcher' when it actually can download files of any type.
module ImageFetcher
  # TODO: seems like this constant is not used at all, except in test.
  # Need to move it to the spec_helper
  ROOT_DIR = File.expand_path("#{File.dirname(__FILE__)}/..")
end
