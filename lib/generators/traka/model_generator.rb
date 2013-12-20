module Traka
  module Generators
    class ModelGenerator < ::Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      desc "Generates the model for recording trakable changes"

      def create_model
        generate "model", "traka_change klass:string uuid:string action_type:string version:integer"

        # TODO: Whatever changes need to be made to the generated model go here...
        # TODO: Create TrakaChange record here.
      end

      def update_model
        copy_file "traka_change.rb", "app/models/traka_change.rb"
      end
    end
  end
end
