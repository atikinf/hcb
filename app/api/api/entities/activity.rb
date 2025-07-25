# frozen_string_literal: true

module Api
  module Entities
    class Activity < Base
      expose :key

      format_as_date do
        expose :created_at
      end

      expose_associated Organization do |activity, options|
        activity.event
      end

      expose_associated User do |activity, options|
        activity.owner.is_a?(User) ? activity.owner : activity.user
      end

      expose_associated Transaction do |activity, options|
        if activity.trackable.try(:hcb_code).is_a?(HcbCode)
          return activity.trackable.try(:hcb_code)
        elsif activity.trackable.try(:hcb_code)
          HcbCode.find_by_hcb_code(activity.trackable.try(:hcb_code))
        elsif (cpt_hcb_code = activity.trackable.try(:canonical_pending_transaction)&.try(:local_hcb_code))
          cpt_hcb_code
        end
      end

    end
  end
end
