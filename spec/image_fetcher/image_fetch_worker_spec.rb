# frozen_string_literal: true

RSpec.describe ImageFetcher::ImageFetchWorker do
  let(:url) { 'https://foo' }
  let(:output_directory) { 'bar' }

  subject(:class_call) do
    described_class.new(url: url,
                        output_directory: output_directory).call
  end

  before do
    allow(ImageFetcher::SaveFile).to receive(:call)
    stub_request(:get, url).to_return(status: 200, body: 'stub_body', headers: {})
  end

  context 'when the request is successfull' do
    it "doesn't raise errors" do
      expect { class_call }.not_to raise_error
    end

    it 'calls SaveFile' do
      class_call
      expect(ImageFetcher::SaveFile).to(
        have_received(:call).with(url: url,
                                  output_directory: output_directory,
                                  contents: 'stub_body')
      )
    end
  end
end
