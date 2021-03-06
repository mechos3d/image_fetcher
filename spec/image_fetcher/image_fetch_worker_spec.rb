# frozen_string_literal: true

RSpec.describe ImageFetcher::ImageFetchWorker do
  let(:url) { 'https://foo' }
  let(:output_directory) { 'bar' }

  subject(:class_call) do
    described_class.new(url: url,
                        output_directory: output_directory).call
  end

  context 'when the request is successfull' do
    before do
      allow(ImageFetcher::SaveFile).to receive(:call)
      stub_request(:get, url).to_return(status: 200, body: 'stub_body', headers: {})
    end

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

  [Faraday::SSLError, Faraday::ConnectionFailed, Faraday::TimeoutError].each do |error_class|
    context "when #{error_class} is raised" do
      before { stub_request(:get, url).to_raise(error_class) }

      it "doesn't raise errors" do
        expect { class_call }.not_to raise_error
      end

      it 'returns Result with error details' do
        result = class_call
        aggregate_failures do
          expect(result.success).to be false
          expect(result.url).to eq(url)
          expect(result.details).to be_a_kind_of(error_class)
          expect(result.error_code).to eq(:connection_error)
        end
      end
    end
  end

  [300, 301, 302, 303, 307, 400, 404, 500].each do |stub_code|
    context "when response was not successfull with http_code #{stub_code}" do
      before do
        stub_request(:get, url).to_return(status: stub_code, body: 'stub_body', headers: {})
      end

      it 'returns Result with error details' do
        result = class_call
        aggregate_failures do
          expect(result.success).to be false
          expect(result.url).to eq(url)
          expect(result.details).to be_a_kind_of(Faraday::Response)
          expect(result.error_code).to eq(:fail_response)
        end
      end
    end
  end

  context 'when given invalid url' do
    context 'with wrong protocol' do
      let(:url) { 'ttps://foo.com' }
      it do
        result = class_call
        aggregate_failures do
          expect(result.success).to be false
          expect(result.url).to eq(url)
          expect(result.details).to eq(nil)
          expect(result.error_code).to eq(:invalid_url)
        end
      end
    end

    context 'when http-client throws URI::InvalidURIError' do
      let(:url) { 'https://----' }
      before { stub_request(:get, url).to_raise(URI::InvalidURIError) }

      it do
        result = class_call
        aggregate_failures do
          expect(result.success).to be false
          expect(result.url).to eq(url)
          expect(result.details).to eq(nil)
          expect(result.error_code).to eq(:invalid_url)
        end
      end
    end
  end
end
