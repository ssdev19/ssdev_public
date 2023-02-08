#

Facter.add(:test1) do
    setcode do
        File.exists?('/opt/pingfederate-11.0.2/pingfederate/server/default')
    end
   end

