class AddTypeAndPhoneNumberToTwoFactorAuthenticators < ActiveRecord::Migration
  def change
    # default: topt
    add_column :casino_two_factor_authenticators, :kind, :integer, default: 0
    add_column :casino_two_factor_authenticators, :extra, :json, default: {}
  end
end
