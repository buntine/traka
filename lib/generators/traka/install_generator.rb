module Traka
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      desc "Installs Traka into the app."

      def create_model
        generate "model", "traka_change klass:string uuid:string action_type:string version:integer"
      end

      def update_model
        copy_file "traka_change.rb", "app/models/traka_change.rb"
      end

      def create_version_file
        directory "public/system/api"
        copy_file "version.txt", "public/system/api/version.txt"
      end
    end
  end
end
