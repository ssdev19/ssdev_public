Facter.add('hardware_platform') do
    setcode do
      Facter::Core::Execution.execute('/bin/uname --hardware-platformd')
    end
  end
