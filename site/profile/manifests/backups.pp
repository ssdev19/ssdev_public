# Backups of files and DBs per Iain's scripts
class profile::backups ( String
  $service1,
){
  file { "/backups/${service1}":
    ensure => 'directory',
    # target => "/backups/${service1}/${year_month_day}",
    ;
  '/backups/dumps/':
    ensure => directory,
    ;
  '/backups/scripts/':
    ensure => directory,
    ;
  '/backups/scripts/library.':
    ensure  => present,
    content => epp('profile/it/graylog_ssl_cfg.epp',
    )
    ;

}

$library = @("EOT")

    | EOT
}
