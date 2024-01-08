## Reboot will be required following the installation of this
class profile::pwm2 {
  class { 'pwm':
    tomcat_manager_allow_cidr    => '140.252.0.0/16',
    tomcat_manager_user          => 'admin',
    tomcat_manager_user_password => 'vagrant',
    pwm_download_url             => 'https://github.com/pwm-project/pwm/releases/download/v2_0_1/pwm-2.0.1.war',
  }
}
