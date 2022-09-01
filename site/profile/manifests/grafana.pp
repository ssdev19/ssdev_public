# Grafana url: http://grafana-x.lsst.org:3000
class profile::grafana {

  class { 'grafana':
    version                  => '9.1.2',
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
  }
}
}
