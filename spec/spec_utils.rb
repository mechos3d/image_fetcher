# frozen_string_literal: true

module ImageFetcher
  module SpecUtils
    def self.clean_tmp_out_directory(dir_name)
      if dir_name.start_with?('./')
        dir = File.absolute_path(dir_name)
        FileUtils.remove_dir(dir) if File.exist?(dir)
      else
        raise('Use only relative path for output_directory to be safe -'\
              ' it is completely removed in tests')
      end
    end
  end
end
