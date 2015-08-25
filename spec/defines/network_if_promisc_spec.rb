#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::if::promisc', :type => 'define' do

  context 'incorrect value: macaddress' do
    let(:title) { 'eth6' }
    let :params do {
      :ensure     => 'up',
      :macaddress => '123456',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-eth6')}.to raise_error(Puppet::Error, /123456 is not a MAC address./)
    end
  end

  context 'required parameters' do
    let(:title) { 'eth1' }
    let :params do {
      :ensure => 'up',
    }
    end
    let :facts do {
      :osfamily        => 'RedHat',
      :macaddress_eth1 => 'fe:fe:fe:aa:aa:aa',
    }
    end
    it { should contain_file('ifcfg-eth1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth1',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth1] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth1', [
        'DEVICE=eth1',
        'HWADDR=fe:fe:fe:aa:aa:aa',
        'PROMISC=yes',
        'ONBOOT=yes',
      ])
    end
    it { should contain_service('network') }
  end

  context 'optional parameters' do
    let(:title) { 'eth3' }
    let :params do {
      :ensure       => 'up',
      :macaddress   => 'ef:ef:ef:ef:ef:ef',
      :userctl      => 'yes',
      :bootproto    => 'dhcp',
      :onboot       => 'yes',
    }
    end
    let :facts do {
      :osfamily        => 'RedHat',
      :macaddress_eth3 => 'fe:fe:fe:aa:aa:aa',
    }
    end
    it { should contain_file('ifcfg-eth3').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth3',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth3] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth3', [
        'DEVICE=eth3',
        'HWADDR=ef:ef:ef:ef:ef:ef',
        'PROMISC=yes',
        'USERCTL=yes',
        'BOOTPROTO=dhcp',
        'ONBOOT=yes',
      ])
    end
    it { should contain_service('network') }
  end

end
