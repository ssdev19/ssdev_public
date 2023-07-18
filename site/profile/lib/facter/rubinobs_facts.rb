# Pingfederate service installed.rb
Facter.add(:pf_svc) do
  setcode do
    File.exists?('/etc/systemd/system/pingfederate.service')
  end
end
  
Facter.add(:yourls_config) do
  setcode do
    File.exists?('/var/www/YOURLS-1.9.2/user/config-sample.php')
  end
end
  # scom.pp
#   class scom {
#     if $pf_svc {
#       service { 'pingfederate.service':
#           ensure => running,
#           enable => true,
#           hasstatus => true,
#           hasrestart => true,
#       }
#     }
#   }