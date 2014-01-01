module Traka
  class Change < ActiveRecord::Base
    self.table_name = "traka_changes"

    attr_accessible :klass, :action_type, :uuid, :version

    is_traka
  end
end
