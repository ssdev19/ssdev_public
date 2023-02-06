#
f FileTest.directory?("/opt/pingfederate-11.0.2/pingfederate/server/default")
    Facter.add("file_exists") do
        setcode { true }
    end
end
