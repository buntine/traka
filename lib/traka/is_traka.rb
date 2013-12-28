module Traka
  module IsTraka
    extend ActiveSupport::Concern
 
    included do
    end
 
    module ClassMethods
      def is_traka(options={})
        before_save :set_version

        include Traka::IsTraka::LocalInstanceMethods
      end

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

      def staged_changes(concise=true)
        changes_for_v(latest_version + 1, concise)
      end

      def changes_for_v(v, concise=true)
        c = where(:version => v)
        concise ? filter_changes(c) : c
      end

      def changes_from(v, concise=true)
        changes_in_range(v, concise=true)
      end

      def changes_in_range(from=1, to=latest_version + 1, concise=true)
        c = where(["version >= ? AND version <= ?", from, to])
        concise ? filter_changes(c) : c
      end

      private

      def version_path
        File.join(
          Rails.root, "public", "system",
          "api", "version.txt")
      end

      def filter_changes(c)
        # TODO: Implement.
        c
      end
    end

    module LocalInstanceMethods
      def set_version
        self.version = self.class.latest_version + 1
      end
    end

  end
end

ActiveRecord::Base.send :include, Traka::IsTraka
