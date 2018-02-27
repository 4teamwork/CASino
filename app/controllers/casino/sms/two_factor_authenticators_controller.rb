require 'rotp'

class CASino::SMS::TwoFactorAuthenticatorsController < CASino::ApplicationController
  include CASino::SessionsHelper
  include CASino::TwoFactorAuthenticatorsHelper
  helper CASino::TwoFactorAuthenticatorsHelper
  include CASino::TwoFactorAuthenticatorProcessor

  before_action :ensure_signed_in

  def set_phone_number; end

  def new
    @two_factor_authenticator = current_user.two_factor_authenticators.create!(
      secret: ROTP::Base32.random_base32,
      kind: :sms,
      extra: { phone_number: phone_number },
    )
    @two_factor_authenticator.notify_user!
  end

  def create
    @two_factor_authenticator = current_user.two_factor_authenticators.where(id: params[:id]).first
    validation_result = validate_one_time_password(params[:code], @two_factor_authenticator)
    case
    when validation_result.success?
      current_user.two_factor_authenticators.where(active: true).delete_all
      @two_factor_authenticator.update_attribute(:active, true)
      flash[:notice] = I18n.t('two_factor_authenticators.successfully_activated')
      redirect_to sessions_path
    when validation_result.error_code == 'INVALID_OTP'
      flash.now[:error] = I18n.t('two_factor_authenticators.invalid_one_time_password')
      render :new
    else
      flash[:error] = I18n.t('two_factor_authenticators.invalid_two_factor_authenticator')
      redirect_to new_two_factor_authenticator_path
    end
  end

  private
  def phone_number
    params.require(:phone_number)
  end
  helper_method :phone_number
end
