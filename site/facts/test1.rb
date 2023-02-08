#

Facter.add(:test1) do
    setcode do
        File.exists?('/tmp/testfile')
    end
   end

