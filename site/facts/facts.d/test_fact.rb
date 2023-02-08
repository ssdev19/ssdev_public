#

Facter.add('testf') do
    setcode do
        File.directory?('/tmp')
    end
   end
