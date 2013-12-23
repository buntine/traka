module Traka
  module Generators
    class UninstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      desc "Uninstalls Traka from the app."

      def destroy_model
        destroy "model", "traka_change"
      end

      def generate_migration_if_necessary
        # Ask (or check) if table exists and then generate migration to remove.
      end

      def delete_version_file
        remove_directory "public/system/api"
      end
    end
  end
end
