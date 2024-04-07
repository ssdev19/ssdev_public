# Graylog
class profile::graylog {
  include java_ks::config  # include opensearch
  $pass_secret = lookup('pass_secret')
  $root_password_sha2 = lookup('root_password_sha2')
  $glog_pwd = lookup('glog_pwd')
  # class { 'java' :
  #   package => 'java-17-openjdk-devel',
  # }
  $fqdn = $facts['networking']['fqdn']

  # package { ['httparty','retries']:
  #   ensure   => present,
  #   provider => 'puppet_gem',
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
    version             => '6.0.14',
  }
  ->class { 'mongodb::server':
    bind_ip       => ['127.0.0.1'],
    set_parameter => ['diagnosticDataCollectionEnabled: false'], 
    # above prvents mongodb from scanning directories which was being blocked by SELinux
  }

# Install OpenSearch repository and packages
  # class { 'opensearch':
  #   version => '2.9.0',
  # }
  $tlskey = lookup('tlskey')
  $tlscert = lookup('tlscert')
  $tlschain = lookup('tlschain')
  $certpwd = lookup('certpwd')
  file { '/etc/ssl/certs/graylog/cacerts.jks' :
    ensure  => file,
    source  => '/usr/share/graylog-server/jvm/lib/security/cacerts',
    replace => false,
    # owner  => 'graylog',
    # group  => 'graylog',
  }
  file {
    '/etc/ssl/certs/graylog/':
      ensure => directory,
      mode   => '0700',
      owner  => 'graylog',
      group  => 'graylog',
      ;
    '/etc/ssl/certs/graylog/graylog.key':
      ensure  => file,
      content => $tlskey.unwrap,
      ;
    '/etc/ssl/certs/graylog/graylog.crt':
      ensure  => file,
      content => $tlscert.unwrap,
      ;
    '/etc/ssl/certs/graylog/graylog.pem':
      ensure  => file,
      content => $tlschain.unwrap,
  }
  # java_ks cannot find keytool, so this symlink is needed
  file { '/usr/local/bin/keytool':
    ensure => link,
    target => '/usr/share/graylog-server/jvm/bin/keytool',
    # require => Class['graylog-server'],
  }
  # java_ks { 'lss.org:/etc/ssl/certs/graylog/cacerts.jks':
  #   ensure              => latest,
  #   certificate         => '/etc/ssl/certs/graylog/graylog.crt',
  #   private_key         => '/etc/ssl/certs/graylog/graylog.key',
  #   chain               => '/etc/ssl/certs/graylog/graylog.pem',
  #   password            => 'changeit',
  #   password_fail_reset => true,
  # }
  # java_ks { 'graylog-ssdev.lsst.org:/etc/ssl/certs/graylog/cacerts.jks':
  #   ensure              => latest,
  #   certificate         => '/etc/ssl/certs/graylog/cert.pem',
  #   private_key         => '/etc/ssl/certs/graylog/privkey.pkcs8.pem',
  #   # chain               => '/etc/ssl/graylog/graylog_ssdev.csr',
  #   password            => 'changeit',
  #   password_fail_reset => true,
  # }

  class { 'graylog::repository':
    version => '5.2',
  }
  ->class { 'graylog::server':
    package_version => '5.2.6',
    config          => {
      is_leader                           => true,
      node_id_file                        => '/etc/graylog/server/node-id',
      password_secret                     => $pass_secret.unwrap,
      root_username                       => 'admin',
      root_password_sha2                  => $root_password_sha2.unwrap,
      root_timezone                       => 'UTC',
      allow_leading_wildcard_searches     => false,
      allow_highlighting                  => false,
      http_bind_address                   => '0.0.0.0:443',
      http_external_uri                   => "https://${fqdn}/",
      http_publish_uri                    => "https://${fqdn}/",
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
    java_opts       => '-Xms4g -Xmx4g -XX:NewRatio=1 -server -XX:+ResizeTLAB -XX:-OmitStackTraceInFastThrow -Djavax.net.ssl.trustStore=/etc/ssl/certs/graylog/cacerts.jks',
  }
# certificate needs to be valid or else the api fails.
  # graylog_api { 'api':
  #   username => 'admin',
  #   password => $glog_pwd,
  #   port     => 443,
  #   tls      => true,
  #   server   => "${fqdn}",
  # }
  graylog_api::input::gelf_tcp { 'A GELF TCP Input with TLS':
    port          => 12202,
    tls_cert_file => '/etc/ssl/certs/graylog/graylog.crt',
    tls_enable    => true,
    tls_key_file  => '/etc/ssl/certs/graylog/graylog.key',
  }
}
