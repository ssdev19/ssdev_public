class profile::mysql {
  class { 'mysql::server': 
    root_password   => '123RTY*^',
    remove_default_accounts => true,
    restart => true,
  } # end of class mysql::server
  mysql::db { 'mydb':
    user => 'jiradbuser',
    password => 'DumbPss#2109874',
    host => 'localhost',
    grant => ['SELECT', 'UPDATE'],
  } # end of mysql db
}
