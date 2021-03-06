module Traka
  module IsTrakable
    extend ActiveSupport::Concern
 
    included do
    end
 
    module ClassMethods
      def is_trakable(options={})
        cattr_accessor :traka_uuid
        self.traka_uuid = (options[:traka_uuid] || :uuid).to_s

        before_create :set_uuid, :record_create
        before_update :set_uuid, :record_update
        before_destroy :set_uuid, :record_destroy

        include Traka::IsTrakable::LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
      private

      def set_uuid
        f = self.class.traka_uuid

        if self.attributes[f].blank?
          write_attribute(self.class.traka_uuid, SecureRandom.hex(20))
        end
      end

      def record_create
        record_traka_change("create")
      end

      def record_update
        record_traka_change("update")
      end

      def record_destroy
        record_traka_change("destroy")
      end

      def record_traka_change(action_type)
        Traka::Change.create(:klass => self.class.to_s,
                             :uuid => self.attributes[self.class.traka_uuid],
                             :action_type => action_type)
      end
    end
  end
end

ActiveRecord::Base.send :include, Traka::IsTrakable
