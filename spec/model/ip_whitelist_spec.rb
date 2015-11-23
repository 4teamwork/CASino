require 'spec_helper'

describe CASino::IPWhitelist do
  describe 'empty' do
    subject { CASino::IPWhitelist.new([]) }

    it 'does not include anything' do
      subject.should_not include("127.0.0.1")
      subject.should_not include("192.168.0.3")
      subject.should_not include("240.17.159.136")
    end
  end

  describe 'fixed ip addresses' do
    subject { CASino::IPWhitelist.new(["127.0.0.1", "192.168.0.1"]) }

    it 'includes exact matches' do
      subject.should include("127.0.0.1")
      subject.should include("192.168.0.1")
    end

    it 'does not include any non-exact matches' do
      subject.should_not include("192.168.0.3")
      subject.should_not include("240.17.159.136")
    end
  end

  describe 'subnets' do
    subject { CASino::IPWhitelist.new(["192.168.3.0/24"]) }

    it 'includes addresses within the subnet' do
      subject.should include("192.168.3.98")
      subject.should include("192.168.3.240")
    end

    it 'does not include addresses outside the subnet' do
      subject.should_not include("240.17.159.136")
      subject.should_not include("192.168.1.10")
    end
  end

  describe 'ranges' do
    subject { CASino::IPWhitelist.new([["192.168.1.10", "192.168.1.15"],
                                       ["172.16.87.1", "172.16.87.140"]]) }

    it 'includes addresses contained within the ranges' do
      subject.should include("192.168.1.13")
      subject.should include("172.16.87.56")
    end

    it 'does not include addresses outside the ranges' do
      subject.should_not include("192.168.1.3")
      subject.should_not include("172.17.10.1")
      subject.should_not include("240.17.159.136")
    end

    it 'includes lower bound' do
      subject.should include("192.168.1.10")
      subject.should_not include("192.168.1.9")
      subject.should include("172.16.87.1")
    end

    it 'includes upper bound' do
      subject.should include("192.168.1.15")
      subject.should_not include("192.168.1.16")
      subject.should include("172.16.87.140")
      subject.should_not include("172.16.87.141")
    end
  end
end
