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
        before_update :record_update
        before_destroy :record_destroy

        include Traka::IsTrakable::LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
      def set_uuid
        write_attribute(self.class.traka_uuid, SecureRandom.hex(20))
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

     private

      def record_traka_change(action_type)
        TrakaChange.create(:klass => self.class,
                           :uuid => self.attributes[self.class.traka_uuid],
                           :action_type => action_type)
      end
    end
  end
end

ActiveRecord::Base.send :include, Traka::IsTrakable
