# SQL DB
class profile::mysql {
  class { 'mysql::server':
    root_password           => 'rootpwd',
    remove_default_accounts => true,
    restart                 => true,
  } # end of class mysql::server
  mysql::db { 'mydb':
    user     => 'mydbuser',
    password => 'mydbpasswd',
    host     => 'localhost',
    grant    => ['SELECT', 'UPDATE'],
  } # end of mysql db
  mysql::db { 'mydb2':
    ensure   => absent,
    user     => 'mydbuser2',
    password => 'mydbpasswd',
    host     => 'localhost',
    grant    => ['SELECT', 'UPDATE'],
  } # end of mysql db
}
