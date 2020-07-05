# frozen_string_literal: true

module ImageFetcher
  class SaveFile
    def self.call(**args)
      new(**args).call
    end

    def initialize(url:, output_directory:, contents:)
      @url              = url
      @output_directory = output_directory
      @contents         = contents
    end

    def call
      if File.exist?(filepath)
        worker_class::Result.new(
          false, url, nil, worker_class::ErrorCodes.file_already_exists
        )
      else
        File.open(filepath, 'w') { |file| file.write(contents) }
      end
    end

    private

    attr_reader :url, :output_directory, :contents

    # TODO: For usability it can be better to create a separate directory
    # for each domain and save files there.

    # TODO: urls can have VERY long filenames in it - better
    # to shorten the name itself here if needed:
    # (uniqeness will still be provided by the MD5 hash)
    def filepath
      @filepath ||= File.join(output_directory, filename)
    end

    # TODO: need a spec on the 'uniqueness' behavior:
    def filename
      name = url.split('/').last
      [Digest::MD5.hexdigest(url), name].join('__')
    end

    def worker_class
      @worker_class ||= ::ImageFetcher::ImageFetchWorker
    end

  end
end
