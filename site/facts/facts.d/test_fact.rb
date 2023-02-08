#

Facter.add('test_fact') do
    setcode do
        File.directory?('/tmp')
    end
   end
