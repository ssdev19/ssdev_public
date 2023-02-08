#

Facter.add('testf') do
    setcode do
        File.exists?('/tmp/testfile')
    end
   end
