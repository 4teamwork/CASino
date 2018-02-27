class CASino::EcallSMSService
  def initialize(username, password)
    @username = username
    @password = password
  end

  def deliver(two_factor_authenticator)
    Rails.logger.warn(
      'SECRET: ' +
      ROTP::TOTP.new(two_factor_authenticator.secret).now
    )
  end
end
