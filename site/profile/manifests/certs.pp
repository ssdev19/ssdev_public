# Graylog cert
class profile::certs {
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
  openssl::certificate::x509 { 'test':
    ensure       => present,
    country      => 'us',
    organization => 'test.com',
    commonname   => $fqdn,
    state        => 'Here',
    locality     => 'Myplace',
    unit         => 'MyUnit',
    altnames     => ['a.com', 'b.com', 'c.com'],
    extkeyusage  => ['serverAuth', 'clientAuth', 'any_other_option_per_openssl'],
    email        => 'contact@foo.com',
    days         => 3456,
    base_dir     => '/var/www/ssl',
    owner        => 'graylog',
    group        => 'graylog',
    password     => 'j(D$',
    force        => false,
    cnf_tpl      => 'profile/cert.epp',
  }
  # openssl::export::pkcs12 { 'foo':
  #   ensure   => 'present',
  #   basedir  => '/etc/pki/tls',
  #   pkey     => '/etc/pki/tls/private.key',
  #   cert     => '/etc/pki/tls/cert.crt',
  #   in_pass  => 'my_pkey_password',
  #   out_pass => 'my_pkcs12_password',
  # }
  # class { 'openssl::certificates':
  #   x509_certs => { '/path/to/certificate.crt' => {
  #       ensure      => 'present',
  #       password    => 'j(D$',
  #       template    => '/other/path/to/template.cnf',
  #       private_key => '/there/is/my/private.key',
  #       days        => 4536,
  #       force       => false,
  #     },
  #     '/a/other/certificate.crt'               => {
  #     ensure      => 'present', },
  #   },
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
