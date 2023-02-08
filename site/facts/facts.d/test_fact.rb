#

Facter.add('test_fact') do
    setcode do
        if File.exist? '/tmp/testfile'
            'true'
    end
   end
