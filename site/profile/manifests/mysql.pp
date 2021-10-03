# SQL DB
class profile::mysql {
  class { 'mysql::server':
    root_password           => 'rootpwd',
    remove_default_accounts => true,
    restart                 => true,
  }
  mysql::db { 'yourlsdb':
    user     => 'yourlsdbuser',
    password => 'yourlsdbpasswd',
    host     => 'localhost',
    grant    => ['SELECT', 'UPDATE'],
  }
}
