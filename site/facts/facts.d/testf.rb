#

Facter.add(:testf) do
    setcode do
        File.exists?('/tmp/testfile1')
    end
   end
