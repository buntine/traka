module Traka
  class Change < ActiveRecord::Base
    self.table_name = "traka_changes"

    attr_accessible :klass, :action_type, :uuid, :version

    before_save :set_version

    class << self
      def latest_version
        begin
          File.read(version_path).to_i
        rescue
          tc = self.last
          v  = tc ? tc.version : 1

          logger.warn "Latest Traka version not found. Defaulting to v#{v}"

          v
        end
      end

      def publish_new_version!
        set_version!(latest_version + 1)
      end

      def set_version!(v)
        File.open(version_path, "w") do |f|
          f.write(v.to_s)
        end
      end

      def changes(opts={})
        opts = {:version => latest_version + 1,
                :filter => true,
                :actions => [],
                :only => []}.merge(opts)

        c = where(["version #{opts[:version].is_a?(Range) ? "in" : ">="} (?)", opts[:version]])

        unless opts[:actions].empty?
          c = c.where(["action_type in (?)", opts[:actions]])
        end

        unless opts[:only].empty?
          c = c.where(["klass in (?)", opts[:only].map(&:to_s)])
        end

        if opts[:filter]
          filter_changes(c)
        else
          c
        end
      end

      private

      def version_path
        File.join(
          Rails.root, "public", "system",
          "api", "version.txt")
      end

      # Filters out obsolete changes in the given set. For example,
      # there is no point giving out 4 "update" changes, just one will
      # suffice. And if you "create" and then "destroy" a record in one
      # changeset, they should cancel each other out.
      # This is not an efficient algorithm. May need to re-think
      # for huge change-sets.
      def filter_changes(changes)
        changes.reject do |c|
          if c.action_type == "create"
            changes.any? { |cc| cc.action_type == "destroy" and cc.uuid == c.uuid }
          elsif c.action_type == "destroy"
            changes.any? { |cc| cc.action_type == "create" and cc.uuid == c.uuid } or
            changes.any? { |cc| cc.action_type == "update" and cc.uuid == c.uuid }
          elsif c.action_type == "update"
            changes.any? { |cc| cc.action_type == "create" and cc.uuid == c.uuid } or
            changes.any? { |cc| cc.action_type == "destroy" and cc.uuid == c.uuid } or
            changes.any? { |cc| cc.action_type == "update" and cc.uuid == c.uuid and cc.id > c.id }
          end
        end
      end
    end

    def get_record
      ar = ActiveRecord::Base.const_get(self.klass)
      ar.where(ar.traka_uuid => self.uuid).first
    end

   private

    def set_version
      self.version = self.class.latest_version + 1
    end
  end
end
