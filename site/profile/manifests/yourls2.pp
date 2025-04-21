# URL Shortener.  Use dnf install nginx instead of the module as it needs to be recompiled.
# @param yourls_db_pass_hide
#  String DB password
# @param yourls_db_user_hide
#  Accepts DB username
# @param yourls_version
#  Accepts yourls_version
# @param nginx_version
#  Accepts nginx_version
class profile::yourls2 (
  Sensitive[String] $yourls_db_pass_hide,
  Sensitive[String] $yourls_db_user_hide,
  String $yourls_version,
  String $nginx_version,
) {
  include mysql::server

  Package {['openldap-devel', 'make', 'yum-utils', 'pcre-devel', 'epel-release']:
    ensure => installed,
  }
}
