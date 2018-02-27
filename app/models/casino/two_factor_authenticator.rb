
class CASino::TwoFactorAuthenticator < ActiveRecord::Base
  belongs_to :user

  enum kind: { topt: 0, sms: 1 }

  scope :active, -> { where(active: true) }

  def self.cleanup
    self.delete_all(['(created_at < ?) AND active = ?', self.lifetime.ago, false])
  end

  def self.lifetime
    CASino.config.two_factor_authenticator[:lifetime_inactive].seconds
  end

  def expired?
    !self.active? && (Time.now - (self.created_at || Time.now)) > self.class.lifetime
  end

  def notify_user!
    if sms?
      sms_service.deliver(self)
    end
  end

  private
  def sms_service
    Rails.application.config.x.sms_service
  end
end
