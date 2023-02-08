#

Facter.add('test_fact') do
    setcode do
        if File.exist? '/tmp/testfile'
    end
   end

   # hardware_platform.rb

Facter.add('hardware_platform') do
    setcode do
      Facter::Core::Execution.execute('/bin/uname --hardware-platform')
    end
  end
  