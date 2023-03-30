# hardware_platform.rb

Facter.add('hardware_platform') do
    setcode do
      Facter::Core::Execution.execute('/bin/uname --hardware-platform')
    end
  end
  
Facter.add(:osfamily) do
  setcode do
    distid = Facter.value(:lsbdistid)
    case distid
    when /RedHatEnterprise|CentOS|Fedora/
      'redhat'
    when 'ubuntu'
      'debian'
    else
      distid
    end
  end
end