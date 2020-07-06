# frozen_string_literal: true

RSpec.describe ImageFetcher::SaveFile do
  subject(:class_call) do
    described_class.new(url: url,
                        output_directory: output_directory,
                        contents: contents).call
  end

  let(:url) { 'https://example.com/dummy.jpg' }
  let(:output_directory) do
    File.join(ImageFetcher::APPLICATION_ROOT_DIR, 'tmp', 'image_fetcher_save_file_spec_out')
  end
  let(:contents) { 'foo' }
  let(:expected_filename) { '518206a31f04728335677bfd912faedb__dummy.jpg' }
  let(:out_file_path) { File.join(output_directory, expected_filename) }

  before do
    FileUtils.mkdir_p(output_directory)
    clean_tmp_dir(output_directory)
  end
  after { clean_tmp_dir(output_directory) }

  it 'creates a file with right contents' do
    class_call
    aggregate_failures do
      expect(File.exist?(out_file_path)).to be true
      expect(File.read(out_file_path)).to eq(contents)
    end
  end

  context 'when file with the same name already exists' do
    before { FileUtils.touch(out_file_path) }

    it 'returns Result with error details' do
      result = class_call
      aggregate_failures do
        expect(result.success).to be false
        expect(result.url).to eq(url)
        expect(result.details).to eq(nil)
        expect(result.error_code).to eq(:file_already_exists)
      end
    end

    it 'doesn\'t write to this file' do
      expect { class_call }.not_to change { File.read(out_file_path) }.from('')
    end
  end

  def clean_tmp_dir(output_directory)
    FileUtils.rm(
      Dir.glob(
        File.join(output_directory, '*')
      )
    )
  end
end
