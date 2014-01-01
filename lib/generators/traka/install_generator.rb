require 'rails/generators/migration'

module Traka
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("../templates", __FILE__)

      desc "Installs Traka into the app."

      def create_migration
        migration_template 'migration.rb', 'db/migrate/create_traka_changes.rb'
      end

      def create_version_file
        directory "public/system"
      end
    end
  end
end
