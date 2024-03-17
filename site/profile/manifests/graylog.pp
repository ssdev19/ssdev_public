# Graylog
class profile::graylog {
  $pass_secret = lookup('pass_secret')
  $root_password_sha2 = lookup('root_password_sha2')
  $glog_pwd = lookup('glog_pwd')
  # include opensearch
  # class { 'java' :
  #   package => 'java-17-openjdk-devel',
  # }

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
      '-Xms2g',
      '-Xmx2g',
    ],
  }
  # -> es_instance_conn_validator { 'graylog' :
  #   server => 'graylog-ssdev.us.lsst.org', #graylog-ssdev.us.lsst.org',
  #   port   => '9200',
  # }
  class { 'mongodb::globals':
    manage_package_repo => true,
    version             => '5.0.25',
  }
  ->class { 'mongodb::server':
    bind_ip => ['127.0.0.1'],
  }

# Install OpenSearch repository and packages
  # class { 'opensearch':
  #   version => '2.9.0',
  # }
  $tlskey = lookup('tlskey')
  $tlscert = lookup('tlscert')
  file { '/etc/ssl/graylog/' :
    ensure => directory,
    mode   => '0700',
    owner  => 'mongod',
    group  => 'mongod',
  }
  file { '/etc/ssl/graylog/graylog_key_pkcs8.pem' :
    ensure  => file,
    content => $tlskey,
  }
  file { '/etc/ssl/graylog/graylog_cert_chain.crt' :
    ensure  => file,
    content => $tlscert,
  }

  class { 'graylog::repository':
    version => '5.1',
  }
  ->class { 'graylog::server':
    package_version => '5.1.12-1',
    config          => {
      is_leader                           => true,
      node_id_file                        => '/etc/graylog/server/node-id',
      password_secret                     => $pass_secret,
      root_username                       => 'admin',
      root_password_sha2                  => $root_password_sha2,
      root_timezone                       => 'Europe/Berlin',
      allow_leading_wildcard_searches     => false,
      allow_highlighting                  => false,
      http_bind_address                   => '0.0.0.0:9000',
      http_external_uri                   => 'https://graylog-ssdev.us.lsst.org:9000/',
      http_enable_tls                     => true,
      http_tls_cert_file                  => '/etc/ssl/graylog/graylog_cert_chain.crt',
      http_tls_key_file                   => '/etc/ssl/graylog/graylog_key_pkcs8.pem',
      # http_tls_key_password               => 'sslkey-password',
      rotation_strategy                   => 'time',
      retention_strategy                  => 'delete',
      elasticsearch_max_time_per_index    => '1d',
      elasticsearch_max_number_of_indices => '30',
      elasticsearch_shards                => '4',
      elasticsearch_replicas              => '1',
      elasticsearch_index_prefix          => 'graylog',
      elasticsearch_hosts                 => 'https://127.0.0.1:9200',
      mongodb_uri                         => 'mongodb://127.0.0.1:27017/graylog',
    },
  }
}
