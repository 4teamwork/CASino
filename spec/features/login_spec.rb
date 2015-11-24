require 'spec_helper'

describe 'Login' do
  include CASino::Engine.routes.url_helpers

  subject { page }

  context 'with two-factor authentication setup' do
    before do
      in_browser(:other) do
        sign_in
        @totp = enable_two_factor_authentication
      end
    end

    context 'with valid username and password' do
      before { sign_in }

      it { should_not have_button('Login') }
      it { should have_button('Continue') }
      its(:current_path) { should == login_path }

      context 'when filling in the correct otp' do
        before do
          fill_in :otp, with: @totp.now
          click_button 'Continue'
        end

        it { should_not have_button('Login') }
        it { should_not have_button('Continue') }
        its(:current_path) { should == sessions_path }
      end

      context 'when filling in an incorrect otp' do
        before do
          fill_in :otp, with: 'aaaaa'
          click_button 'Continue'
        end

        it { should have_text('The one-time password you entered is not correct') }
        it { should have_button('Continue') }
      end

      context 'access from whitelisted ip' do
        before do
          CASino.config.two_factor_authenticator[:whitelist] = ["127.0.0.1"]
          sign_in
        end
        after { CASino.config.two_factor_authenticator[:whitelist] = [] }

        it { should_not have_button('Login') }
        it { should_not have_button('Continue') }
        its(:current_path) { should == sessions_path }
      end

      context 'access outside whitelist' do
        before do
          CASino.config.two_factor_authenticator[:whitelist] = ["192.168.2.0/24"]
          sign_in
          fill_in :otp, with: @totp.now
          click_button 'Continue'
        end
        after { CASino.config.two_factor_authenticator[:whitelist] = [] }

        it { should_not have_button('Login') }
        its(:current_path) { should == sessions_path }
      end
    end
  end

  context 'without two-factor authentication setup' do
    context 'with valid username and password' do
      before { sign_in }

      it { should_not have_button('Login') }
      its(:current_path) { should == sessions_path }
    end

    context 'access from whitelisted ip' do
      before do
        CASino.config.two_factor_authenticator[:whitelist] = ["127.0.0.1"]
        sign_in
      end
      after { CASino.config.two_factor_authenticator[:whitelist] = [] }

      it { should_not have_button('Login') }
      it { should_not have_button('Continue') }
      its(:current_path) { should == sessions_path }
    end

    context 'access outside whitelist' do
      before do
        CASino.config.two_factor_authenticator[:whitelist] = ["192.168.2.0/24"]
        sign_in
      end
      after { CASino.config.two_factor_authenticator[:whitelist] = [] }

      it { should have_text('Second factor not configured') }
      its(:current_path) { should == login_path }
    end
  end

  context 'with invalid username' do
    before { sign_in username: 'lalala', password: 'foobar123' }

    it { should have_button('Login') }
    it { should have_text('Incorrect username or password') }
  end

  context 'with blank password' do
    before { sign_in password: '' }

    it { should have_button('Login') }
    it { should have_text('Incorrect username or password') }
  end

  context 'with remember me disabled' do
    before { CASino.config.ticket_granting_ticket[:lifetime_long_term] = -1 }
    after { CASino.config.ticket_granting_ticket[:lifetime_long_term] = 864000 }
    before { visit login_path }

    it { should_not have_field('rememberMe') }
  end

  context 'with remember me enabled' do
    before { visit login_path }

    it { should have_field('rememberMe') }
  end
end
