# frozen_string_literal: true

RSpec.describe ImageFetcher::SaveFile do
  subject(:class_call) do
    described_class.new(url: url,
                        output_directory: output_directory,
                        contents: contents).call
  end

  let(:url) { 'https://example.com/dummy.jpg' }
  let(:output_directory) do
    # TODO: if this constant ImageFetcher::ROOT_DIR will not be needed in real code
    # - better to define it only for specs in 'spec_helper.rb' for example:
    # and the same goes for other specs using it
    File.join(ImageFetcher::ROOT_DIR, 'tmp', 'image_fetcher_save_file_spec_out')
  end
  let(:contents) { 'foo' }
  let(:expected_filename) { '518206a31f04728335677bfd912faedb__dummy.jpg' }

  before do
    FileUtils.mkdir_p(output_directory)
    clean_tmp_dir(output_directory)
  end
  after { clean_tmp_dir(output_directory) }

  it 'creates a file with right contents' do
    class_call
    aggregate_failures do
      file = File.join(output_directory, expected_filename)
      expect(File.exists?(file)).to be true
      expect(File.read(file)).to eq(contents)
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
