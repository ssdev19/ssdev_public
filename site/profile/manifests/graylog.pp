# Graylog
class profile::graylog {
  include java_ks::config  # include opensearch
  $pass_secret = lookup('pass_secret')
  $root_password_sha2 = lookup('root_password_sha2')
  $glog_pwd = lookup('glog_pwd')
  # class { 'java' :
  #   package => 'java-17-openjdk-devel',
  # }
  package { ['httparty','retries']:
    ensure   => present,
    provider => 'puppet_gem',
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
    version             => '6.0.14',
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
  file { '/etc/ssl/certs/graylog/' :
    ensure => directory,
    mode   => '0700',
    owner  => 'graylog',
    group  => 'graylog',
  }
  file { '/etc/ssl/certs/graylog/graylog.key' :
    ensure  => file,
    content => $tlskey,
  }
  file { '/etc/ssl/certs/graylog/graylog.crt' :
    ensure  => file,
    content => $tlscert,
  }
  java_ks { 'lsst.org:/etc/ssl/certs/graylog/cacerts':
    ensure              => latest,
    certificate         => '/etc/ssl/certs/graylog/graylog.crt',
    private_key         => '/etc/ssl/certs/graylog/graylog.key',
    # chain               => '/etc/ssl/graylog/graylog.csr',
    password            => 'changeit',
    password_fail_reset => true,
  }

  class { 'graylog::repository':
    version => '5.2',
  }
  ->class { 'graylog::server':
    package_version => '5.2.5',
    config          => {
      is_leader                           => true,
      node_id_file                        => '/etc/graylog/server/node-id',
      password_secret                     => $pass_secret.unwrap,
      root_username                       => 'admin',
      root_password_sha2                  => $root_password_sha2.unwrap,
      root_timezone                       => 'Europe/Berlin',
      allow_leading_wildcard_searches     => false,
      allow_highlighting                  => false,
      http_bind_address                   => '0.0.0.0:443',
      http_external_uri                   => 'https://graylog-ssdev.lsst.org:9000/',
      http_enable_tls                     => true,
      http_tls_cert_file                  => '/etc/ssl/certs/graylog/graylog.crt',
      http_tls_key_file                   => '/etc/ssl/certs/graylog/graylog.key',
      # http_tls_key_password               => 'pwdtest',
      rotation_strategy                   => 'time',
      retention_strategy                  => 'delete',
      elasticsearch_max_time_per_index    => '1d',
      elasticsearch_max_number_of_indices => '30',
      elasticsearch_shards                => '4',
      elasticsearch_replicas              => '1',
      elasticsearch_index_prefix          => 'graylog',
      elasticsearch_hosts                 => 'http://127.0.0.1:9200',
      mongodb_uri                         => 'mongodb://127.0.0.1:27017/graylog',
    },
    java_opts       => ' -Djavax.net.ssl.trustStore=/etc/ssl/certs/graylog/cacerts',
  }
# certificate needs to be valid or else the api fails.
  # graylog_api { 'api':
  #   username => 'admin',
  #   password => $glog_pwd,
  #   port     => 443,
  #   tls      => true,
  #   server   => 'graylog-ssdev.lsst.org',
  # }
}
