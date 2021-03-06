module BadgeGrant
  module Granter
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      #
      # context = { flash: ActionDispatch::Flash object,
      #             event: symbol,
      #             params: hash }
      #
      # === Example
      #
      #   .call flash: flash,
      #         event: :test_passage_complete,
      #         params: { resource: @test_passage,
      #                   user: @user }
      #         
      def call(context)
        context[:flash] ||= false
        return if events[context[:event]].nil?
        grant_badges(flash: context[:flash],
                     rules: events[context[:event]][:rules],
                     params: context[:params])
      end

      private

      #
      # params = flash: ActionDispatch::Flash object,
      #          rules: array,
      #          params: hash
      #
      def grant_badges(params)
        rules = params[:rules]
        flash = params[:flash]
        params = params[:params]

        rules.each do |rule|
          params[:badge] = Badge.active.find_by(rule: rule)
          next if params[:badge].nil?
          create_flash_message(flash, params[:badge]) if send(rule, params) && flash
        end
      end

      def create_flash_message(flash, badge)
        flash[badge.rule] = I18n.t('badges.was_granted', badge_title: badge.title)
      end

      def grant_badge_safely(badge)
        grant_badge(badge) if badge_grant_valid?(badge)
      end

      def grant_badge(badge)
        UserBadge.create!(grant_badge_params(badge))
      end

      def grant_badge_params(params)
        { user: params[:user],
          badge: params[:badge],
          resource: params[:resource],
          resource_type: resource_type(params[:resource]) }
      end

      def resource_type(resource)
        resource.class.to_s
      end

      def badge_grant_valid?(params)
        return true if params[:badge].multiple
        return true unless params[:user].have_badge?(params[:badge].id)

        false
      end
    end
  end
end
