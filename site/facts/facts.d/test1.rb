#

Facter.add('test1') do
    setcode do
        Directory.exists?("/opt/pingfederate-11.0.2/pingfederate/server/default")
    end
   end

