# Pingfederate service installed.rb
Facter.add(:pf_svcs) do
    setcode do
      File.exists?('/etc/systemd/system/pingfederate.service')
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