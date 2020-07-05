# frozen_string_literal: true

RSpec.describe ImageFetcher::OutputReportGenerator do
  subject(:class_call) { described_class.call(results) }

  context 'when given both successfull and failed results' do
    let(:successfull_results) do
      3.times.map { ImageFetcher::ImageFetchWorker::Result.new(true, '', nil, nil) }
    end
    let(:failed_results) do
      2.times.map { ImageFetcher::ImageFetchWorker::Result.new(false, '', nil, nil) }
    end

    let(:results) { successfull_results + failed_results }

    it 'prints the report' do
      expect(class_call).to eq(
        <<~REPORT
          Total number of unique urls: 5,
          Successfully downloaded: 3,
          Failures: 2
        REPORT
      )
    end
  end
end
