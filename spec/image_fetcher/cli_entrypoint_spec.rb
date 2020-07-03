# frozen_string_literal: true

RSpec.describe ImageFetcher::CliEntrypoint do
  subject(:class_call) do
    described_class.new(argv: argv, argf: argf).call
  end

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

  context 'when argument is a relative path to directory' do
    let(:argument) { './some/dir' }

    it 'calls main processor' do
      allow(ImageFetcher::MainProcessor).to receive(:call)
      class_call
      expect(ImageFetcher::MainProcessor).to have_received(:call).with(
        urls: expected_urls,
        output_directory: expected_output_dir,
      )
    end
  end

  context 'when argument is an absolute path to directory' do
    let(:argument) { '/some/dir' }

    it 'calls main processor' do
      allow(ImageFetcher::MainProcessor).to receive(:call)
      class_call
      expect(ImageFetcher::MainProcessor).to have_received(:call).with(
        urls: expected_urls,
        output_directory: argument,
      )
    end
  end
end
