module Traka
  class Change < ActiveRecord::Base
    attr_accessible :klass, :action_type, :uuid, :version

    is_traka
  end
end
