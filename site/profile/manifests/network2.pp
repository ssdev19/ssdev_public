
class profile::network2 { #($interfaces = hiera('interfaces',false)) {
  # if ($interfaces != false) {
  include 'network'
  $interfaces = hiera('interfaces',false)
  if $interfaces {
    create_resources ( network_config, $interfaces )
  }
}
