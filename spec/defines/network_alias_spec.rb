#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::alias', :type => 'define' do

  context 'incorrect value: ensure' do
    let(:title) { 'eth1:1' }
    let :params do {
      :ensure    => 'blah',
      :ipaddress => '1.2.3.4',
      :netmask   => '255.255.255.0',
      :restart   => true,
      :sched     => nil,
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-eth1:1')}.to raise_error(Puppet::Error, /\$ensure must be "up", "down", or "absent"./)
    end
  end

  context 'incorrect value: ipaddress' do
    let(:title) { 'eth1:1' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => 'notAnIP',
      :netmask   => '255.255.255.0',
      :restart   => true,
      :sched     => nil,
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-eth1:1')}.to raise_error(Puppet::Error, /notAnIP is not an IP address./)
    end
  end

  context 'required parameters' do
    let(:title) { 'bond2:1' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => '1.2.3.6',
      :netmask   => '255.255.255.0',
      :restart   => true,
      :sched     => nil,
    }
    end
    let :facts do {
      :osfamily   => 'RedHat',
    }
    end
    it { should contain_file('ifcfg-bond2:1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond2:1',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-bond2:1] with required contents' do
      verify_contents(catalogue, 'ifcfg-bond2:1', [
        'DEVICE=bond2:1',
        'BOOTPROTO=none',
        'ONPARENT=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.6',
        'NETMASK=255.255.255.0',
        'NO_ALIASROUTING=no',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

  context 'required parameters: ensure => absent' do
    let(:title) { 'bond2:1' }
    let :params do {
      :ensure    => 'absent',
      :ipaddress => '1.2.3.6',
      :netmask   => '255.255.255.0',
      :restart   => true,
      :sched     => nil,
    }
    end
    let :facts do {
      :osfamily        => 'RedHat',
      :interfaces => 'eth0,bond2:1',
    }
    end
    it { is_expected.to contain_file('ifcfg-bond2:1').with(
      :ensure => 'absent',
    )}
    it { should contain_service('network') }
  end

  context 'optional parameters' do
    let(:title) { 'bond3:2' }
    let :params do {
      :ensure         => 'down',
      :ipaddress      => '33.2.3.127',
      :netmask        => '255.255.0.0',
      :gateway        => '33.2.3.1',
      :noaliasrouting => true,
      :userctl        => true,
      :metric         => '10',
      :zone           => 'trusted',
      :restart        => true,
      :sched          => nil,
    }
    end
    let :facts do {
      :osfamily   => 'RedHat',
    }
    end
    it { should contain_file('ifcfg-bond3:2').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond3:2',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-bond3:2] with required contents' do
      verify_contents(catalogue, 'ifcfg-bond3:2', [
        'DEVICE=bond3:2',
        'BOOTPROTO=none',
        'ONPARENT=no',
        'TYPE=Ethernet',
        'IPADDR=33.2.3.127',
        'NETMASK=255.255.0.0',
        'GATEWAY=33.2.3.1',
        'NO_ALIASROUTING=yes',
        'USERCTL=yes',
        'ZONE=trusted',
        'METRIC=10',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

  context 'optional parameters: restart => false' do
    let(:title) { 'bond2:1' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => '1.2.3.6',
      :netmask   => '255.255.255.0',
      :restart   => false,
      :sched     => nil,
    }
    end
    let :facts do {
      :osfamily   => 'RedHat',
    }
    end
    it { should contain_file('ifcfg-bond2:1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond2:1',
    )}
    it 'should contain File[ifcfg-bond2:1] with required contents' do
      verify_contents(catalogue, 'ifcfg-bond2:1', [
        'DEVICE=bond2:1',
        'BOOTPROTO=none',
        'ONPARENT=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.6',
        'NETMASK=255.255.255.0',
        'NO_ALIASROUTING=no',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { is_expected.to_not contain_file('ifcfg-bond2:1').that_notifies('Service[network]') }
  end

  context 'optional parameters: ifscripts => true, ensure => up' do
    let(:title) { 'bond2:1' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => '1.2.3.6',
      :netmask   => '255.255.255.0',
      :restart   => true,
      :sched     => nil,
      :ifscripts => true,
    }
    end
    let :facts do {
      :osfamily   => 'RedHat',
      :interfaces => 'eth0',
    }
    end
    it { should contain_file('ifcfg-bond2:1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond2:1',
    )}
    it 'should contain File[ifcfg-bond2:1] with required contents' do
      verify_contents(catalogue, 'ifcfg-bond2:1', [
        'DEVICE=bond2:1',
        'BOOTPROTO=none',
        'ONPARENT=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.6',
        'NETMASK=255.255.255.0',
        'NO_ALIASROUTING=no',
        'NM_CONTROLLED=no',
      ])
    end
    it { is_expected.to contain_file('ifcfg-bond2:1') }
    it { is_expected.to contain_exec('Refresh bond2:1') }
  end

  context 'optional parameters: ifscripts => true, ensure => absent' do
    let(:title) { 'bond2:1' }
    let :params do {
      :ensure    => 'absent',
      :ipaddress => '1.2.3.6',
      :netmask   => '255.255.255.0',
      :restart   => true,
      :sched     => nil,
      :ifscripts => true,
    }
    end
    let :facts do {
      :osfamily        => 'RedHat',
      :interfaces => 'eth0,bond2:1',
    }
    end
    it { is_expected.to contain_file('ifcfg-bond2:1').with(
      :ensure => 'absent',
    )}
    it { is_expected.to contain_exec('ifdown bond2:1') }
  end

end
