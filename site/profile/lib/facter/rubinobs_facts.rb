# Pingfederate service installed.rb
Facter.add(:pf_svc) do
  setcode do
    File.exists?('/etc/systemd/system/pingfederate.service')
  end
end
  
Facter.add(:yourls_config) do
  setcode do
    File.exists?('/var/www/html/YOURLS/user/config.php')
  end
end
Facter.add(:yourls_db) do
  setcode do
    File.exists?('/tmp/mysql-db-yourls.gz')
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