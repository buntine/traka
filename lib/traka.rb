require 'traka/is_trakable'
require 'traka/change'

module Traka
  class Railtie < Rails::Railtie
    config.app_generators do |g|
      g.templates.unshift File::expand_path('../templates', __FILE__)
    end 
  end
end
