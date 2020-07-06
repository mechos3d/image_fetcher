# frozen_string_literal: true

module ImageFetcher
  class CliEntrypoint
    EXIT_CODES = {
      success: 0,
      one_of_input_files_doesnt_exist: 1,
      failed_results_present: 2
    }.freeze
    private_constant :EXIT_CODES

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

      results = MainProcessor.call(urls: urls, output_directory: output_directory)

      stdout.puts OutputReportGenerator.call(results)

      exit_code = results.all?(&:success) ? :success : :failed_results_present
      exit(EXIT_CODES.fetch(exit_code))
    end

    private

    attr_reader :argv, :argf, :stdout, :stderr

    def urls
      argf.readlines.map { |url_string| url_string.strip.chomp }
    rescue Errno::ENOENT => e
      stderr.puts e.message
      exit(EXIT_CODES[:one_of_input_files_doesnt_exist])
    end
  end
end
