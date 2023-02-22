# Grafana url: http://grafana-x.lsst.org:3000
# Keys containg dots should be within quotes.
class profile::grafana {

  class { 'grafana':
    version                  => '9.3.6',
    provisioning_datasources => {
    apiVersion  => 1,
    datasources => [
      {
        name      => 'prometheus',
        type      => 'prometheus',
        access    => 'proxy',
        url       => 'http://prometheus.us.lsst.org:9090/',
        isDefault => true,
      },
    ],
    },
    cfg                      => {
      'auth.ldap' => {
        enabled     => true,
        config_file => '/etc/grafana/ldap.toml',
      },
      server      => {
        http_port => 3000,
        cert_key  => '/etc/grafana/grafana.key',
        cert_file => '/etc/grafana/grafana.crt',
        protocol  => 'https',
        change_grafana_admin_password => 'admin1',
      },
    }
  }

  $domaincert = lookup('domaincert')
  archive { '/etc/grafana/grafana.crt' :
    ensure  => present,
    source  => $domaincert,
    cleanup => false,
  }
  $domaincert2 = lookup('domaincert2')
  archive { '/etc/grafana/grafana.key' :
    ensure  => present,
    source  => $domaincert2,
    cleanup => false,
  }
}
