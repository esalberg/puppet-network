# == Definition: network::validate_ip_address
#
# This definition can be used to call is_ip_address on an array of ip addresses.
#
# === Parameters:
#
# None
#
# === Actions:
#
# === Sample Usage:
#
# $ips = [ '10.21.30.248', '123:4567:89ab:cdef:123:4567:89ab:cdef' ]
# network::validate_ip_address { $ips: }
#
define network::validate_ip_address {
  if ! is_ip_address($name) { fail("${name} is not an IP(v6) address.") }
} # define network::validate_ip_address
