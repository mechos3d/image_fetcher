# frozen_string_literal: true

RSpec.describe ImageFetcher::Utils do

  describe '.filename_from_url' do
    let(:url1) { 'https://foo.com/ii/foo.jpg' }

    it 'returns formatted filename' do
      expect(described_class.filename_from_url(url1)).to eq(
        'ce13918c6934e504e35e11df5b4266f6__foo.jpg'
      )
    end

    context 'for files with the same domain and name but different filepath' do
      let(:url2) { 'https://foo.com/iiiiiii/foo.jpg' }

      it 'returns different filenames' do
        result1 = described_class.filename_from_url(url1)
        result2 = described_class.filename_from_url(url2)

        expect(result1).not_to eq(result2)
      end
    end

    context 'for files from different domains but the same filepath' do
      let(:url2) { 'https://barbar.com/ii/foo.jpg' }

      it 'returns different filenames' do
        result1 = described_class.filename_from_url(url1)
        result2 = described_class.filename_from_url(url2)

        expect(result1).not_to eq(result2)
      end
    end
  end

  describe '.valid_url?(url)' do
    subject(:method_call) { described_class.valid_url?(url) }

    valid_urls = [
      'https://foo.com/bar.jpg',
      'https://foo.com/bar',
      'https://foo.com/bar#stuff',
      'https://foo.com/bar?param1=1&params2=1']

    valid_urls.each do |url|
      context "when given a valid url: #{url}" do
        let(:url) { url }
        it { is_expected.to be true }
      end
    end

    invalid_urls = [
      'ttps://foo.com',
      'https://non-ascii-кириллица'
    ]
    invalid_urls.each do |url|
      context "when given an invalid url: #{url}" do
        let(:url) { url }
        it { is_expected.to be false }
      end
    end
  end
end
