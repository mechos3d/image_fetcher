# frozen_string_literal: true

module ImageFetcher
  class CliEntrypoint

    def initialize(argv: ARGV, argf: ARGF, stdout: STDOUT, stderr: STDERR)
      @argv   = argv
      @argf   = argf
      @stdout = stdout
      @stderr = stderr
    end

    # TODO: implement the '--help' flag
    def call
      argument = argv.shift
      output_directory = File.absolute_path(argument)

      # TODO: if given '--help' flag - return from the method here
      # before the ARGF or else it will block waiting for
      # the input indefinitely
      check_input_file_exists

      urls = argf.readlines.map { |url_string| url_string.strip.chomp }
      results = MainProcessor.call(urls: urls, output_directory: output_directory)

      stdout.puts OutputReportGenerator.call(results)
      exit(2) unless results.all?(&:success)
    end

    private

    attr_reader :argv, :argf, :stdout, :stderr

    # TODO: add a spec for this:
    def check_input_file_exists
      file = argv.first
      return if File.exist?(File.absolute_path(file))
      stderr.puts "No such file: #{file}"
      exit(1)
    end
  end
end
