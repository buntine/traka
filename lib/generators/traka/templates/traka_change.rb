class TrakaChange < ActiveRecord::Base
  attr_accessible :klass, :action_type, :uuid, :version

  before_save :set_version

  # TODO: Implement.
  def self.latest_version
    1
  end

  def self.staged_changes
    changes_for_v(self.latest_version + 1)
  end

  def self.changes_for_v(v)
    self.where(:version => v)
  end

 private

  def set_version
    self.version = self.latest_version + 1
  end

end
