# Graylog
class profile::graylog {
  file { '/etc/ssl/graylog':
    ensure => directory,
  }
  $my_ip   = $::ipaddress
  $fqdn    = $facts['networking']['fqdn']
  $domaincert = lookup('domaincert')
  $glog_pwd = lookup('glog_pwd')
  # archive { '/tmp/lsstcertlatest.crt' :
  #   ensure  => present,
  #   source  => $domaincert,
  #   cleanup => false,
  # }
  # $domaincert2 = lookup('domaincert2')
  # archive { '/tmp/lsstcertlatest.key' :
  #   ensure  => present,
  #   source  => $domaincert2,
  #   cleanup => false,
  # }
  # $chain = lookup('chain')
  # archive { '/tmp/lsstcertlatestintermediate.pem' :
  #   ensure  => present,
  #   source  => $chain,
  #   cleanup => false,
  # }
  #   file { '/etc/ssl/graylog/graylog_cert_chain.crt':
  #   ensure  => present,
  #   source  => '/tmp/lsstcertlatest.crt',
  #   replace => 'no',
  #   mode    => '0644',
  #   owner   => 'graylog',
  #   group   => 'graylog',
  # }
  #   file { '/etc/ssl/graylog/graylog_key_pkcs8.pem':
  #   ensure  => present,
  #   source  => '/tmp/lsstcertlatestintermediate.pem',
  #   replace => 'no',
  #   mode    => '0644',
  #   owner   => 'graylog',
  #   group   => 'graylog',
  # }

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
  manage_package      => true,
  version             => '6.0.4',
}
-> class { 'mongodb::server':
  bind_ip        => [ '127.0.0.1' ],
  ensure         => 'present',
  restart        => true,
  service_enable => true,
}
class { 'elastic_stack::repo':
  version => 7,
  oss     => true,
}
#  /usr/lib/sysctl.d/elasticsearch.conf; config file: /etc/elasticsearch/elasticsearch.yml
class { 'elasticsearch':
  version           => '7.10.2', #Currently 7.11 and above not supported in Graylog
  oss               => true,
  # ensure => 'absent',
  manage_repo       => true,
  restart_on_change => true,
  config            => {
    'cluster.name' => 'graylog',
    'network.host' => '127.0.0.1',
  },
  jvm_options       => [
    '-Xms1g',
    '-Xmx1g'
  ]
}
-> es_instance_conn_validator { 'graylog' :
    server => '127.0.0.1', #graylog-ssdev.us.lsst.org',
    port   => '9200',
  }
# Support for elasticsearch multi instance has been remove so cannot user: elasticsearch::instance
# config file: /etc/graylog/server/server.conf
# Password must be at least 16 character long and complex or the service will not start
  class { '::graylog::repository':
    version => '5.0' # Installs the latest available release of the version
  }
  -> class { '::graylog::server':
      package_version => '5.0.2',
      config          => {
        is_master                           => true,
        node_id_file                        => '/etc/graylog/server/node-id',
        password_secret                     => $glog_pwd,
        root_username                       => 'admin',
        root_password_sha2                  => 'c65570ad975136d09ae3d3deafc2c0463b400ffdc9be6f6707f112997b599377',
        root_timezone                       => 'UTC',
        allow_leading_wildcard_searches     => true,
        allow_highlighting                  => true,
        http_bind_address                   => '0.0.0.0:9000',
        http_external_uri                   => 'http://graylog-ssdev.lsst.org:9000/',
        # http_enable_tls                     => true,
        # http_tls_cert_file                  => '/etc/ssl/graylog/cert.pem',
        # http_tls_key_file                   => '/etc/ssl/graylog/pkcs5-plain.pem',
        # http_tls_key_password               => 'changeit',
        rotation_strategy                   => 'time',
        retention_strategy                  => 'delete',
        elasticsearch_max_time_per_index    => '1d',
        elasticsearch_max_number_of_indices => '30',
        elasticsearch_shards                => '4',
        elasticsearch_replicas              => '1',
        elasticsearch_index_prefix          => 'graylog',
        elasticsearch_hosts                 => 'http://localhost:9200',
        mongodb_uri                         => 'mongodb://127.0.0.1/graylog',
      },
      require         => Class[
        '::java',
      ],
  }
}
