class CASino::TwoFactorController < CASino::ApplicationController
  include CASino::SessionsHelper

  before_action :ensure_signed_in

  def choose; end

  def destroy
    authenticators = current_user.two_factor_authenticators.where(id: params[:id])
    if authenticators.any?
      authenticators.first.destroy
      flash[:notice] = I18n.t('two_factor_authenticators.successfully_deleted')
    end
    redirect_to sessions_path
  end
end
