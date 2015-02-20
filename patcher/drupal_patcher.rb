require 'fileutils'

class DrupalPatcher
  class << self
    def patch(module_archive, patch)
      # Prepare directory
      dirname = "temp/#{Time.now.getutc.to_i.to_s}"
      Dir.mkdir dirname

      Dir.chdir dirname do
        # Upload module
        module_file = module_archive[:tempfile]
        module_name = module_archive[:filename]
        FileUtils.cp module_file.path, "./#{module_name}"
        # Upload patch
        patch_file = patch[:tempfile]
        patch_name = patch[:filename]
        FileUtils.cp patch_file.path, "./#{patch_name}"
        # Extract archive
        extract module_name
        # Patch module
        output = `patch < #{patch_name} && rm #{patch_name}`
        # Compress result
        file = compress module_name
        # Return data
        { file: "#{dirname.split("/").last}/#{file}", output: output }
      end
    rescue => e
      "Aborted! Error: #{e}"
    end

    private
      def extract(filename)
        case ext_to_sym(filename)
        when :gz
          `tar --strip-components=1 -xzf #{filename} && rm #{filename}`
        when :zip
          `unzip #{filename} && rm #{filename}`
        end
      rescue => e
        "Cannot extract file! Error: #{e}"
      end

      def compress(filename)
        `zip -r #{filename}_patched.zip .`
        "#{filename}_patched.zip"
      rescue => e
        "Cannot compress files! Error: #{e}"
      end

      def ext_to_sym(filename)
        filename.split(".").last.to_sym
      end
  end
end
