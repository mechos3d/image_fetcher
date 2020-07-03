# frozen_string_literal: true

module ImageFetcher
  class CliEntrypoint

    # def initialize(argv: ARGV, argf: ARGF, stdout: STDOUT, stderr: STDERR)
    def initialize(argv: ARGV, argf: ARGF)
      @argv   = argv
      @argf   = argf
    end

    # TODO: implement the '--help' flag
    def call
      argument = argv.shift

      output_directory = File.absolute_path(argument)

      # TODO: if given '--help' flag - return here before the ARGF or else it will block waiting for
      # the input indefinitely
      urls = argf.readlines.map { |url_string| url_string.strip.chomp }

      MainProcessor.call(urls: urls, output_directory: output_directory)

      # TODO: rescue 'Errno::ENOENT' and return some user-friendly error
    end

    private

    attr_reader :argv, :argf
  end
end
