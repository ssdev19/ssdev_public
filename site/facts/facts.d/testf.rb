#

Facter.add(:testf) do
    setcode do
        ! Dir.glob('/tmp/testfile').empty?
    end
   end
