class TrakaChange < ActiveRecord::Base
  attr_accessible :klass, :action_type, :uuid, :version
end