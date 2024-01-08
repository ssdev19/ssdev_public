## Reboot will be required following the installation of this
#
# @summary
#   A Puppet module for managing Pwm:
#
#   https://github.com/pwm-project/pwm
#
#   Note that the module expects to find pwm.war at the root of the Puppet 
#   fileserver. This could be avoided if Pwm was packaged for Debian.
#
# @param pwm_download_url
#   The URL from which to download the PWM WAR file
# @param pwm_context
#   Context (path) of Pwm on the Tomcat installation
# @param manage
#   Whether to manage Pwm or not
# @param manage_config
#   Whether to manage Pwm configuration or not
# @param manage_tomcat
#   Whether to manage Tomcat or not
# @param tomcat_webapps_path
#   Webapps directory for Tomcat
# @param tomcat_catalina_host
#   Name of the Pwm host for Tomcat  
# @param tomcat_manager_allow_cidr
#   CIDR blocks to allow traffic from to Tomcat Manager webapp
# @param tomcat_manager_user
#   Username for accessing Tomcat Manager
# @param tomcat_manager_user_password
#   Password for Tomcat Manager user
# @param tomcat_java_opts
#   Tomcat's JAVA_OPTS setting
#
class profile::pwm2 {
  class { 'pwm':
    tomcat_manager_allow_cidr    => '192.168.59.0/24',
    tomcat_manager_user          => 'admin',
    tomcat_manager_user_password => 'vagrant',
    pwm_download_url             => 'https://github.com/pwm-project/pwm/releases/download/v2_0_1/pwm-2.0.1.war',
  }
}
