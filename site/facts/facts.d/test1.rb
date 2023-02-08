#

Facter.add('test1') do
    setcode do
        Facter::Core::Execution.execute("/opt/pingfederate-11.0.2/pingfederate/server/default")
    end
   end

