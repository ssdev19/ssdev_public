#

Facter.add(:testf) do
    setcode do
      if  File.exists?('/tmp/testfile')
        'true'
    end
   end
