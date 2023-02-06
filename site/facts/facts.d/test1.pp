if((test-path '/opt/pingfederate-11.0.2/pingfederate/server/default1') -or (test-path '/opt/pingfederate-11.0.2/pingfederate/server1')){
    write-host "test_file_exists=true
}
else{
  write-host "test_file_exists=false"
}