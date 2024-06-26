
class profile::network2 { #($interfaces = hiera('interfaces',false)) {
  # if ($interfaces != false) {
  include 'network'
  # $interfaces = hiera('interfaces',false)
  # if $interfaces {
  #   create_resources ( network_config, $interfaces )
  # }

  # $rules = hiera('interfaces')
  # $defaults = {
  #   netmask => '255.255.252.0',
  # }
  # create_resources('network_config', $rules)

  create_resources('network_config', hiera('network_config'))
}
