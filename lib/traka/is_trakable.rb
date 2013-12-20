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
      end
    end

    def set_uuid
      write_attribute(self.class.traka_uuid, SecureRandom.hex(20))
    end

    def record_create
    end

    def record_update
    end

    def record_destroy
    end
  end
end

ActiveRecord::Base.send :include, Traka::IsTrakable
