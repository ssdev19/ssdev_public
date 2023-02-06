if((test-path '/opt/pingfederate-11.0.2/pingfederate/server/defaulte') -or (test-path '/opt/pingfederate-11.0.2/pingfederate/servere')){
    write-host "test_file_exists=true
}
else{
  write-host "test_file_exists=false"
}