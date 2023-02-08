#

Facter.add(:test1) do
    setcode do
     if Dir.exist? ('/opt/pingfederate-11.0.2/pingfederate/server/default')
      'one'
    #  elsif Dir.exist? ('/mydir2')
    #   'two'
     else
      'default'
     end
    end
   end