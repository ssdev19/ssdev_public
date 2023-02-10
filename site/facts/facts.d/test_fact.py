#

Facter.add('test_fact') do
    setcode do
        File.exist?('/tmp/testfile')
            'true'
    end
   end

   # hardware_platform.rb

# Facter.add('hardware_platform') do
#     setcode do
#       Facter::Core::Execution.execute('/bin/uname --hardware-platform')
#     end
#   end
