# frozen_string_literal: true

RSpec.describe ImageFetcher::MainProcessor do
  subject(:class_call) do
    described_class.call(urls: urls,
                         output_directory: output_directory)
  end

  let(:urls) { [url1, url2] }
  let(:url1) { 'https://foo.com/foo.jpg' }
  let(:url2) { 'https://foo.com/bar.png' }
  let(:output_directory) do
    File.join(ImageFetcher::APPLICATION_ROOT_DIR, 'tmp', 'main_processor_spec_out')
  end

  before { allow(ImageFetcher::ImageFetchWorker).to receive(:call) }

  context 'when the output directory doesn\'t exist' do
    it 'creates the directory' do
      FileUtils.rm_rf(output_directory, secure: true)
      class_call
      expect(File.exist?(output_directory)).to be true
    end

    it 'for each url it calls ImageFetchWorker' do
      class_call
      urls.each do |url|
        expect(ImageFetcher::ImageFetchWorker).to(
          have_received(:call).with(url: url, output_directory: output_directory)
                              .exactly(1).time
        )
      end
    end
  end

  context 'when the output directory already exists' do
    it 'for each url it calls ImageFetchWorker' do
      class_call
      urls.each do |url|
        expect(ImageFetcher::ImageFetchWorker).to(
          have_received(:call).with(url: url, output_directory: output_directory)
                              .exactly(1).time
        )
      end
    end
  end

  context 'when urls in the input are duplicated' do
    let(:url1) { 'https://foo.com' }
    let(:url2) { 'https://foo.com' }
    let(:urls) { [url1, url2] }

    it 'calls ImageFetchWorker only once for each url' do
      class_call
      expect(ImageFetcher::ImageFetchWorker).to(
        have_received(:call).with(url: url1, output_directory: output_directory)
                            .exactly(1).time
      )
    end
  end
end
