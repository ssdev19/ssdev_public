# Graylog cert
class profile::graylog {


  $domaincert = lookup('domaincert')
  archive { '/tmp/lsstcertlatest.crt' :
    ensure  => present,
    source  => $domaincert,
    cleanup => false,
  }
  $domaincert2 = lookup('domaincert2')
  archive { '/tmp/lsstcertlatest.key' :
    ensure  => present,
    source  => $domaincert2,
    cleanup => false,
  }
  $chain = lookup('chain')
  archive { '/tmp/lsstcertlatestintermediate.pem' :
    ensure  => present,
    source  => $chain,
    cleanup => false,
  }
  $keystore = lookup('keystore')
  archive { '/etc/pki/keystore' :
    ensure  => present,
    source  => $keystore,
    cleanup => false,
  }

  $keystore_location = '/etc/pki/keystore'

# Define any additional parameters for generating the keystore
  $keystore_password = lookup('keystore_password')
  $keystore_alias = lookup('keystore_alias')
  $certificate_path = lookup('certificate_path')
  $private_key_path = lookup('private_key_path')

  # Generate the keystore
  # exec { 'generate_keystore':
  #   command => "openssl pkcs12 -export -out ${keystore_location} -in ${certificate_path} -inkey ${private_key_path} -name ${keystore_alias} -password pass:${keystore_password}",
  #   creates => $keystore_location,
  # }

  # # Ensure correct permissions on the keystore file
  # file { $keystore_location:
  #   owner   => 'graylog',
  #   group   => 'graylog',
  #   mode    => '0644',
  #   require => Exec['generate_keystore'],
  # }
  $keystorepwd = lookup('keystorepwd')
  # java_ks { 'lsst.org:/etc/pki/keystore':
  #   ensure              => latest,
  #   certificate         => '/tmp/lsstcertlatest.crt',
  #   private_key         => '/tmp/lsstcertlatest.key',
  #   chain               => '/tmp/lsstcertlatestintermediate.pem',
  #   password            => $keystorepwd,
  #   password_fail_reset => true,
  # }
}
