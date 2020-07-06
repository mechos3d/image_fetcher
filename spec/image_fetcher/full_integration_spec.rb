# frozen_string_literal: true

RSpec.describe ImageFetcher::CliEntrypoint do
  subject(:class_call) { described_instance.call }

  let(:described_instance) do
    described_class.new(argv: argv, argf: argf, stdout: stdout, stderr: stderr)
  end
  let(:argument) { './tmp/full_integration_spec_out_directory' }

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
  let(:stdout) do
    double.tap do |stdout_double|
      allow(stdout_double).to receive(:puts)
    end
  end
  let(:stderr) do
    double.tap do |stderr|
      allow(stderr).to receive(:puts)
    end
  end
  after do
    ImageFetcher::SpecUtils.clean_tmp_out_directory(argument)
  end

  context 'successful path' do
    let(:urls_raw_contents) do
      ["https://foo/bar1.jpg\n",
       "https://foo/bar2.jpg\n",
       "https://foo/bar3.jpg\n"]
    end

    before do
      stub_request(:get, 'https://foo/bar1.jpg')
        .to_return(status: 200, body: 'stub_body_1')

      stub_request(:get, 'https://foo/bar2.jpg')
        .to_return(status: 200, body: 'stub_body_2')

      stub_request(:get, 'https://foo/bar3.jpg')
        .to_return(status: 200, body: 'stub_body_3')

      ImageFetcher::SpecUtils.clean_tmp_out_directory(argument)
      allow(described_instance).to receive(:exit)
    end

    it 'creates files with right contents' do
      class_call
      dir = File.absolute_path(argument)
      file_contents = Dir.children(dir).map do |file|
        File.read(File.join(dir, file))
      end
      expect(file_contents).to match_array(%w[stub_body_1 stub_body_2 stub_body_3])
    end

    it 'returns report to user' do
      class_call
      expect(stdout).to have_received(:puts).with(
        <<~REPORT
          Total number of unique urls: 3,
          Successfully downloaded: 3,
          Failures: 0
        REPORT
      )
    end

    it 'exits with zero code exit(0)' do
      class_call
      expect(described_instance).to have_received(:exit).with(0)
    end
  end

  context 'when failed requests present' do
    let(:urls_raw_contents) do
      ["https://foo/bar1.jpg\n",
       "https://foo/bar2.jpg\n"]
    end

    before do
      stub_request(:get, 'https://foo/bar1.jpg')
        .to_return(status: 200, body: 'stub_body_1', headers: {})

      stub_request(:get, 'https://foo/bar2.jpg')
        .to_return(status: 404, body: nil, headers: {})

      ImageFetcher::SpecUtils.clean_tmp_out_directory(argument)
      allow(described_instance).to receive(:exit)
    end

    it 'creates the files for which the request was successfull' do
      class_call
      dir = File.absolute_path(argument)
      file_contents = Dir.children(dir).map do |file|
        File.read(File.join(dir, file))
      end
      expect(file_contents).to match_array(%w[stub_body_1])
    end

    it 'returns report to user' do
      class_call
      expect(stdout).to have_received(:puts).with(
        <<~REPORT
          Total number of unique urls: 2,
          Successfully downloaded: 1,
          Failures: 1
        REPORT
      )
    end

    it 'exits with non-zero code exit(2)' do
      class_call
      expect(described_instance).to have_received(:exit).with(2)
    end
  end
end
