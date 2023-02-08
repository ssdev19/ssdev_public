#

Facter.add('test_fact') do
    setcode do
        if File.exist? '/tmp/testfile'
    end
   end
