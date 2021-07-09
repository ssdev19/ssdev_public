# webserver
class profile::webserver {
  Package { [ 'drush' ]:
  ensure => installed,
  }
}
