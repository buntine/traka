require 'traka/is_trakable'
require 'traka/is_traka'

module Traka

  class Railtie < Rails::Railtie
    config.app_generators do |g|
      g.templates.unshift File::expand_path('../templates', __FILE__)
    end 
  end

end
