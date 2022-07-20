# Graylog
class profile::graylog {
    file { '/etc/ssl/graylog':
      ensure => directory,
    }

  $fqdn    = $facts['networking']['fqdn']
  $domaincert = lookup('domaincert')
  archive { '/tmp/lsstcertlatest.crt' :
    ensure  => present,
    source  => $domaincert,
    cleanup => false,
  }
  $domaincert2 = lookup('domaincert2')
  archive { '/tmp/lsstcertlatest.key' :
    ensure  => present,
    source  => $domaincert2,
    cleanup => false,
  }
  $chain = lookup('chain')
  archive { '/tmp/lsstcertlatestintermediate.pem' :
    ensure  => present,
    source  => $chain,
    cleanup => false,
  }
    file { '/etc/ssl/graylog/graylog_cert_chain.crt':
    ensure  => present,
    source  => '/tmp/lsstcertlatest.crt',
    replace => 'no',
  }
    file { '/etc/ssl/graylog/graylog_key_pkcs8.pem':
    ensure  => present,
    source  => '/tmp/lsstcertlatestintermediate.pem',
    replace => 'no',
  }

  # $keystorepwd = lookup('keystorepwd')
  # java_ks { 'lsst.org:/etc/pki/keystore':
  #   ensure              => latest,
  #   certificate         => '/tmp/lsstcertlatest.crt',
  #   private_key         => '/tmp/lsstcertlatest.key',
  #   password            => $keystorepwd,
  #   password_fail_reset => true,
  # }
class { 'mongodb::globals':
  manage_package_repo => true,
}
-> class { 'mongodb::server':
  bind_ip => ['127.0.0.1'],
}
class { 'elastic_stack::repo':
  version => 7,
}
class { 'elasticsearch':
  version     => '7.9.3',
  # repo_version => '8.x',
  # ensure => 'absent',
  manage_repo => true,
  jvm_options => [
  '-Xms1g',
  '-Xmx1g'
  ]
}
# Support for elasticsearch multi instance has been remove so cannot user: elasticsearch::instance
  class { '::graylog::repository':
    version => '4.2'
  }
  -> class { '::graylog::server':
      config  => {
        is_master                           => true,
        node_id_file                        => '/etc/graylog/server/node-id',
        password_secret                     => 'password',
        root_username                       => 'admin',
        root_password_sha2                  => '6b3a55e0261b0304143f805a24924d0c1c44524821305f31d9277843b8a10f4e',
        root_timezone                       => 'UTC',
        allow_leading_wildcard_searches     => true,
        allow_highlighting                  => true,
        http_bind_address                   => '0.0.0.0:9000',
        http_external_uri                   => "https://${fqdn}:9000/",
        http_enable_tls                     => true,
        http_tls_cert_file                  => '/etc/ssl/graylog/graylog_cert_chain.crt',
        http_tls_key_file                   => '/etc/ssl/graylog/graylog_key_pkcs8.pem',
        # http_tls_key_password               => 'changeit',
        rotation_strategy                   => 'time',
        retention_strategy                  => 'delete',
        elasticsearch_max_time_per_index    => '1d',
        elasticsearch_max_number_of_indices => '30',
        elasticsearch_shards                => '4',
        elasticsearch_replicas              => '1',
        elasticsearch_index_prefix          => 'graylog',
        elasticsearch_hosts                 => "http://${fqdn}:9200,http://${fqdn}:9200",
        mongodb_uri                         => "mongodb://mongouser:mongopass@${fqdn}:27017",
      },
      require => Class[
        '::java',
      ],
  }

}
