#

Facter.add('test1') do
    setcode do
        ! Dir.glob("/opt/pingfederate-11.0.2/pingfederate/server/defaulta").empty?
    end
   end

