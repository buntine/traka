module Traka
  module Generators
    class ModelGenerator < ::Rails::Generators::Base
      desc "Generates the model for recording trakable changes"

      def create_model
        generate "model", "klass:string uuid:string action_type:string version:integer"

        # Whatever changes need to be made to the generated model go here...
      end
    end
  end
end
