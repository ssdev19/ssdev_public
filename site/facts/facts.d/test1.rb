#
f FileTest.directory?("/opt/pingfederate-11.0.2/pingfederate/server/default")
    Facter.add("test1") do
        setcode { true }
    end
end
