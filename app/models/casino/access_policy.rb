module CASino::AccessPolicy
  class ExternalLoginNotAllowed < StandardError; end
  class TwoFactorNotConfigured < StandardError; end

  def self.get(user, user_ip, user_data)
    context = Context.new user, user_ip, user_data
    if CASino.config.two_factor_authenticator[:whitelist].empty?
      Basic.new context
    else
      InternalExternal.new context, CASino.config.two_factor_authenticator
    end
  end

  class Context < Struct.new(:user, :user_ip, :user_data)
    def user_groups
      @user_groups ||= Array(user_data[:extra_attributes]['groups']).map(&:downcase)
    end

    def username
      user_data[:username]
    end

    def two_factor_configured?
      !user.active_two_factor_authenticator.nil?
    end
  end

  class Basic < Struct.new(:context)
    def verify!
      # no-op
    end

    def two_factor?
      context.two_factor_configured?
    end
  end

  class InternalExternal < Struct.new(:context, :config)
    def verify!
      if external_access?
        if !external_access_allowed?
          raise ExternalLoginNotAllowed, "User (#{context.username}) not in allowed groups for external access"
        end
        if !context.two_factor_configured?
          raise TwoFactorNotConfigured
        end
      end
    end

    def two_factor?
      external_access?
    end

    private

    def external_access_allowed?
      return true if allowed_groups.empty?

      (allowed_groups & context.user_groups).any?
    end

    def external_access?
      !internal_access?
    end

    def internal_access?
      whitelist.include?(context.user_ip)
    end

    def allowed_groups
      @allowed_groups ||= Array(config[:allowed_groups]).map(&:downcase)
    end

    def whitelist
      @whitelist ||= CASino::IPWhitelist.new(config[:whitelist])
    end
  end
end
