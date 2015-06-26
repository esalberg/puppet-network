# == Definition: network::bond::slave
#
# Creates a bonded slave interface.
#
# === Parameters:
#
#   $macaddress   - optional, defaults to macaddress_$title
#   $master       - required
#   $ethtool_opts - optional
#   $userctl      - optional
#   $bootproto    - optional
#   $onboot       - optional
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Requires:
#
#   Service['network']
#
# === Sample Usage:
#
#   network::bond::slave { 'eth1':
#     macaddress => $::macaddress_eth1,
#     master     => 'bond0',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
#
define network::bond::slave (
  $macaddress,
  $master,
  $ethtool_opts = undef,
  $userctl = undef,
  $bootproto = undef,
  $onboot = undef,
) {
  include '::network'

  $interface = $name

  if ! is_mac_address($macaddress) {
    # Strip off any tailing VLAN (ie eth5.90 -> eth5).
    $title_clean = regsubst($title,'^(\w+)\.\d+$','\1')
    $macaddy = getvar("::macaddress_${title_clean}")
  } else {
    $macaddy = $macaddress
  }

  # Validate our data
  if ! is_mac_address($macaddy) {
    fail("${macaddy} is not a MAC address.")
  }

  file { "ifcfg-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}",
    content => template('network/ifcfg-bond.erb'),
    before  => File["ifcfg-${master}"],
    notify  => Service['network'],
  }
} # define network::bond::slave
