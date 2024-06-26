# Prometheus monitoring URL: http://prometheus.us.lsst.org:9090/ # @param slackapi_hide
# @param slackapi_hide
#  Accept Slack API
# @param slackuser_hide
#  Accept Slack user
# @param cluster_hide
#  Cluster config
# @param advertise_ip
#  IP for cluster
class profile::prometheus (
  Sensitive[String] $slackapi_hide,
  Sensitive[String] $slackuser_hide,
  Sensitive[String] $cluster_hide,
  String $advertise_ip,
) {
# Firewall rules are in private repo
  include prometheus
  include prometheus::snmp_exporter
  # include prometheus::rabbitmq_exporter
  class { 'prometheus::blackbox_exporter':
    version => '0.24.0',
    modules => {
      'http_2xx'    => {
        'prober'  => 'http',
        'timeout' => '10s',
        'http'    => {
          'valid_status_codes'    => [],
          'method'                => 'GET',
          'preferred_ip_protocol' => 'ip4',
        },
      },
      'tcp_connect' => {
        'prober' => 'tcp',
      },
      'icmp'        => {
        'prober'  => 'icmp',
        'timeout' => '10s',
        'icmp'    => {
          'preferred_ip_protocol' => 'ip4',
          'ip_protocol_fallback'  => true,
        },
      },
    },
  }
# Alertmanager config
  file { '/etc/alertmanager/notifications.tmpl':
    ensure  => file,
    content => epp('profile/alertmanager_custom.epp'),
  }
  $gmail_auth_token = lookup('gmail_auth_token')
  $gmail_account = lookup('gmail_account')
  $to_account = lookup('to_account')
  class { 'prometheus::alertmanager':
    # extra_options => '--cluster.listen-address=',
    extra_options => "--cluster.advertise-address=${advertise_ip} \--cluster.listen-address=:9797 \--cluster.peer=${unwrap($cluster_hide)}",
    version       => '0.27.0',
    # global    => {
    #   'resolve_timeout' => '1m',
    #   'to'              => 'wf@belldex.com',
    #   'from'            => $gmail_account,
    #   'smarthost'       => 'smtp.gmail.com:587',
    #   'auth_username'   => true,
    #   'auth_identity'   => $gmail_account,
    #   'auth_password'   => $gmail_auth_token,
    #   },
    # route         => {
    #   'group_by'        => ['alertname', 'job'],
    #   'group_wait'      => '30s',
    #   'group_interval'  => '1m',
    #   'repeat_interval' => '3h',
    #   'receiver'        => 'slack',
    # },
    receivers     => [
      # { 'name'          => 'email',
      #   'email_configs' => [
      #     {
      #       'to'            => $to_account,
      #       'from'          => $gmail_account,
      #       'smarthost'     => 'smtp.gmail.com:587',
      #       'auth_username' => $gmail_account,
      #       'auth_identity' => $gmail_account,
      #       'auth_password' => $gmail_auth_token,
      #       'require_tls'   => true,
      #       'send_resolved' => true,
      #     },
      #   ],
      # },
      { 'name'          => 'slack',
        'slack_configs' => [
          {
            'api_url'       => unwrap($slackapi_hide),
            'channel'       => '#ssdev_monitoring',
            'icon_url'      => 'http://i.imgur.com/VcwymZj.jpg',
            'username'      => unwrap($slackuser_hide),
            'title'         => '{{ template "custom_title" . }}',
            'text'          => '{{ template "custom_slack_message" . }}',
            'send_resolved' => true,
            # 'text'          => '{{ .GroupLabels.app }}/{{ .GroupLabels.alertname }}',
          },
        ],
      },
    ],
  }
  #   exec { 'Allow any user to use icmp ':
  #   path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
  #   # onlyif  => 'grep -q 4294967295 /etc/.....',
  #   command => "sysctl net.ipv4.ping_group_range='0 2147483647'",
  # }
}
