module Traka
  module Generators
    class ModelGenerator < ::Rails::Generators::Base
      #source_root File.expand_path("../templates", __FILE__)
      desc "Generates the model for recording trakable changes"

      def create_model
        create_file Rails.root.join("config", "ghey.rb"), "This is ghey"
      end
    end
  end
end
