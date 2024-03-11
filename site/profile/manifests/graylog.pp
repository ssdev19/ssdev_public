# Graylog
class profile::graylog {
  $pass_secret = lookup('pass_secret')
  $root_password_sha2 = lookup('root_password_sha2')

  class { 'mongodb::globals':
    manage_package_repo => true,
  }
  ->class { 'mongodb::server':
    bind_ip => ['127.0.0.1'],
  }

  class { 'opensearch':
    version => '2.9.0',
  }

  class { 'graylog::repository':
    version => '5.1'
  }
  ->class { 'graylog::server':
    package_version => '5.1.0-6',
    config          => {
      'password_secret'    => $pass_secret,    # Fill in your password secret
      'root_password_sha2' => $root_password_sha2, # Fill in your root password hash
    },
  }
}
