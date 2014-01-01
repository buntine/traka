module Traka
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      desc "Installs Traka into the app."

      def create_migration
        generate "migration", "traka_change klass:string uuid:string action_type:string version:integer"
      end

      def create_version_file
        directory "public/system"
      end
    end
  end
end
