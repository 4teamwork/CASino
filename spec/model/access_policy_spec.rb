require 'spec_helper'

describe CASino::AccessPolicy::InternalExternal do
  describe '#verify!' do
    let(:username) { 'jane' }
    let!(:user) { FactoryGirl.create :user, username: username }
    let!(:two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator, user: user }

    def build_policy(allowed_groups: [])
      described_class.new(
        context,
        whitelist: ["10.0.0.1"],
        allowed_groups: allowed_groups)
    end

    def build_context(current_user_groups: [])
      CASino::AccessPolicy::Context.new(
        user,
        "112.203.19.193",
        username: username,
        extra_attributes: { 'groups' => current_user_groups })
    end

    context 'lower case current user group' do
      let(:context) do
        build_context(current_user_groups: ["foo"])
      end

      context "with upper case allowed group" do
        subject { build_policy(allowed_groups: ["Foo"]) }

        it "should allow access" do
          expect{ subject.verify! }.not_to raise_error
        end
      end

      context "with lower case allowed group" do
        subject { build_policy(allowed_groups: ["foo"]) }

        it "should allow access" do
          expect{ subject.verify! }.not_to raise_error
        end
      end
    end

    context 'upper case current user group' do
      let(:context) do
        build_context(current_user_groups: ["Foo"])
      end

      context "with upper case allowed group" do
        subject { build_policy(allowed_groups: ["Foo"]) }

        it "should allow access" do
          expect{ subject.verify! }.not_to raise_error
        end
      end

      context "with lower case allowed group" do
        subject { build_policy(allowed_groups: ["Foo"]) }

        it "should allow access" do
          expect{ subject.verify! }.not_to raise_error
        end
      end
    end
  end
end
