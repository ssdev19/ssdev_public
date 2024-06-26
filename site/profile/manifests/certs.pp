# Graylog cert
# @param country
# @param state
# @param locality
# @param organization
# @param canonical_name
# @param days
# @param server_ip
# set RANDFILE=.rnd
class profile::certs (
  Integer $days,
  # String $country,
  String $state,
  String $locality,
  String $organization,
  String $canonical_name,
  String $server_ip,
) {
  $fqdn = $facts['networking']['fqdn']
####################
####################
####################
####################
####################
  class { 'openssl':
    package_ensure         => latest,
    ca_certificates_ensure => latest,
  }
  openssl::certificate::x509 { 'graylog_ssdev':
    ensure       => present,
    country      => 'us',
    organization => 'lsst.org',
    commonname   => 'graylog-ssdev.lsst.org',
    state        => 'az',
    # locality     => 'Myplace',
    # unit         => 'MyUnit',
    altnames     => ['graylog-ssdev.lsst.org', '140.252.32.189'],
    # extkeyusage  => ['serverAuth', 'clientAuth', 'any_other_option_per_openssl'],
    # email        => 'contact@foo.com',
    days         => $days,
    base_dir     => '/etc/ssl/certs/graylog',
    owner        => 'graylog',
    group        => 'graylog',
    password     => 'pwdtest',
    force        => false,
    # cnf_tpl      => 'profile/cert.epp',
  }
  # openssl::export::pem_key { 'graylog_pem':
  #   ensure   => 'present',
  #   basedir  => '/etc/ssl/certs/graylog',
  #   pkey     => '/etc/ssl/certs/graylog/graylog_ssdev.key',
  #   cert     => '/etc/ssl/certs/graylog/graylog_ssdev.crt',
  #   in_pass  => 'my_pkey_password',
  #   out_pass => 'my_pkcs12_password',
  # }

  # openssl::export::pkcs12 { 'foo':
  #   ensure   => 'present',
  #   basedir  => '/etc/ssl/certs/graylog',
  #   pkey     => '/etc/ssl/certs/graylog/graylog_ssdev.key',
  #   cert     => '/etc/ssl/certs/graylog/graylog_ssdev.crt',
  #   in_pass  => 'my_pkey_password',
  #   out_pass => 'my_pkcs12_password',
  # }
#   $domaincert = lookup('domaincert')
#   archive { '/tmp/lsstcertlatest.crt' :
#     ensure  => present,
#     source  => $domaincert,
#     cleanup => false,
#   }
#   $domaincert2 = lookup('domaincert2')
#   archive { '/tmp/lsstcertlatest.key' :
#     ensure  => present,
#     source  => $domaincert2,
#     cleanup => false,
#   }
#   $chain = lookup('chain')
#   archive { '/tmp/lsstcertlatestintermediate.pem' :
#     ensure  => present,
#     source  => $chain,
#     cleanup => false,
#   }
#   $keystore = lookup('keystore')
#   archive { '/etc/pki/keystore' :
#     ensure  => present,
#     source  => $keystore,
#     cleanup => false,
#   }

#   $keystore_location = '/etc/pki/keystore'

# # Define any additional parameters for generating the keystore
#   $keystore_password = lookup('keystore_password')
#   $keystore_alias = lookup('keystore_alias')
#   $certificate_path = lookup('certificate_path')
#   $private_key_path = lookup('private_key_path')

#   # # Ensure correct permissions on the keystore file
#   # file { $keystore_location:
#   #   owner   => 'graylog',
#   #   group   => 'graylog',
#   #   mode    => '0644',
#   #   require => Exec['generate_keystore'],
#   # }
#   $keystorepwd = lookup('keystorepwd')
#   # java_ks { 'lsst.org:/etc/pki/keystore':
#   #   ensure              => latest,
#   #   certificate         => '/tmp/lsstcertlatest.crt',
#   #   private_key         => '/tmp/lsstcertlatest.key',
#   #   chain               => '/tmp/lsstcertlatestintermediate.pem',
#   #   password            => $keystorepwd,
#   #   password_fail_reset => true,
#   # }
}
