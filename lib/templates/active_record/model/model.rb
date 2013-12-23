class TrakaChange < ActiveRecord::Base
  attr_accessible :klass, :action_type, :uuid, :version

  before_save :set_version

  def self.latest_version
    begin
      File.read(
        File.join(
          Rails.root, "public", "system",
          "api", "version.txt")).to_i
    rescue
      tc = TrakaChange.last
      v  = tc ? tc.version + 1 : 1

      logger.warn "Latest Traka version not found. Defaulting to v#{v}"

      v
    end
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
