# == Definition: network::if::promisc
#
# Creates a promiscuous interface.
#
# === Parameters:
#
#   $ensure        - required - up|down
#   $macaddress   - optional, defaults to macaddress_$title
#   $userctl      - optional
#   $bootproto    - optional
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
#   network::if::promisc { 'eth1':
#     ensure => 'up',
#   }
#
#   network::if::promisc { 'eth1':
#     ensure => 'up',
#     macaddress => aa:bb:cc:dd:ee:ff,
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
define network::if::promisc (
  $ensure,
  $macaddress = undef,
  $userctl    = false,
  $bootproto  = undef,
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

  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')
  # Validate booleans
  validate_bool($userctl)

  # Validate our data
  if ! is_mac_address($macaddy) {
    fail("${macaddy} is not a MAC address.")
  }

  $onboot = $ensure ? {
    'up'    => 'yes',
    'down'  => 'no',
    default => undef,
  }

  file { "ifcfg-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}",
    content => template('network/ifcfg-promisc.erb'),
    notify  => Service['network'],
  }
} # define network::if::promisc
