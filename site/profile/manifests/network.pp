# Network config
# @param ipaddress
class profile::network (
  String $ipaddress
) {
  include 'network'
  network_config { 'eth0':
    ensure    => 'present',
    family    => 'inet',
    ipaddress => $ipaddress,
    method    => 'static',
    netmask   => '255.255.254.0',
    onboot    => 'true',
    options   => {
      'GATEWAY'   => '140.252.32.1',
      'DNS1'      => '140.252.32.125',
      'DNS2'      => '140.252.32.126',
      'DNS3'      => '140.252.32.127',
    },
  }
}
