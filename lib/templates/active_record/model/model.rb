class TrakaChange < ActiveRecord::Base
  attr_accessible :klass, :action_type, :uuid, :version

  before_save :set_version

  def self.latest_version
    begin
      File.read(version_path).to_i
    rescue
      tc = TrakaChange.last
      v  = tc ? tc.version : 1

      logger.warn "Latest Traka version not found. Defaulting to v#{v}"

      v
    end
  end

  def self.publish_new_version!
    set_version!(latest_version + 1)
  end

  def self.set_version!(v)
    File.open(version_path, "w") do |f|
      f.write(v.to_s)
    end
  end

  def self.staged_changes(concise=true)
    changes_for_v(self.latest_version + 1, concise)
  end

  def self.changes_for_v(v, concise=true)
    c = self.where(:version => v)
    concise ? filter_changes(c) : c
  end

  def self.changes_from(v, concise=true)
    changes_in_range(v, concise=true)
  end

  def self.changes_in_range(from=1, to=latest_version + 1, concise=true)
    c = self.where(["version >= ? AND version <= ?", from, to])
    concise ? filter_changes(c) : c
  end

 private

  def set_version
    self.version = TrakaChange.latest_version + 1
  end

  def self.version_path
    File.join(
      Rails.root, "public", "system",
      "api", "version.txt")
  end

  def self.filter_changes(c)
    # TODO: Implement.
    c
  end

end
