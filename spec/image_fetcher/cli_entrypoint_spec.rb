# frozen_string_literal: true

RSpec.describe ImageFetcher::CliEntrypoint do
  subject(:class_call) { described_instance.call }

  let(:described_instance) do
    described_class.new(argv: argv, argf: argf)
  end
  let(:argument) { './tmp/some/dir' }
  let(:urls_raw_contents) do
    ["   https://foo/bar1.jpg   \n",
     "  https://foo/bar2.jpg \n"]
  end
  let(:expected_urls) do
    ['https://foo/bar1.jpg', 'https://foo/bar2.jpg']
  end
  let(:expected_output_dir) { File.absolute_path(argument) }

  let(:argv) do
    double.tap do |argv_double|
      allow(argv_double).to receive(:shift).and_return(argument)
    end
  end
  let(:argf) do
    double.tap do |argf_double|
      allow(argf_double).to receive(:readlines).and_return(urls_raw_contents)
    end
  end

  before do
    allow(described_instance).to receive(:exit)
    allow(ImageFetcher::MainProcessor).to receive(:call).and_return([])
    allow(ImageFetcher::OutputReportGenerator).to receive(:call)
  end

  context 'when argument is a relative path to directory' do
    let(:argument) { './tmp/some/dir' }

    it 'calls main processor' do
      class_call
      expect(ImageFetcher::MainProcessor).to have_received(:call).with(
        urls: expected_urls,
        output_directory: expected_output_dir
      )
    end
  end

  context 'when argument is an absolute path to directory' do
    let(:argument) { '/tmp/some/dir' }

    it 'calls main processor' do
      class_call
      expect(ImageFetcher::MainProcessor).to have_received(:call).with(
        urls: expected_urls,
        output_directory: argument
      )
    end
  end

  context 'when input file doesn\'t exist' do
    let(:argf) do
      double.tap do |argf_double|
        allow(argf_double).to receive(:readlines).and_raise(Errno::ENOENT)
      end
    end

    it 'exits with non-zero exit_code(1) and logs to STDERR' do
      allow(ImageFetcher::Logger).to receive(:log_error)
      class_call
      aggregate_failures do
        expect(ImageFetcher::Logger).to have_received(:log_error).with('No such file or directory')
        expect(described_instance).to have_received(:exit).with(1)
      end
    end
  end
end
