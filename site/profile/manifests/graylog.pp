# Graylog
class profile::graylog {
  $pass_secret = lookup('pass_secret')
  $root_password_sha2 = lookup('root_password_sha2')
  $glog_pwd = lookup('glog_pwd')
  # include opensearch
  class { 'mongodb::globals':
    manage_package_repo => true,
  }
  ->class { 'mongodb::server':
    bind_ip => ['127.0.0.1'],
  }

  # class { 'opensearch':
  #   version => '2.9.0',
  # }

  class { 'graylog::repository':
    version => '5.2',
  }
  ->class { 'graylog::server':
    package_version => '5.2.5',
    config          => {
      is_leader                           => true,
      node_id_file                        => '/etc/graylog/server/node-id',
      password_secret                     => $pass_secret,
      root_username                       => 'admin',
      root_password_sha2                  => $root_password_sha2,
      root_timezone                       => 'Europe/Berlin',
      allow_leading_wildcard_searches     => true,
      allow_highlighting                  => true,
      http_bind_address                   => '0.0.0.0:9000',
      http_external_uri                   => 'https://graylog-ssdev.us.lsst.org:9000/',
      # http_enable_tls                     => true,
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
      elasticsearch_hosts                 => 'http://localhost:9200',
      mongodb_uri                         => 'mongodb://127.0.0.1/graylog',
    },
  }
}
