# Backups of files and DBs per Iain's scripts
class profile::backups ( String
  $service1,
  $bucketlocation,
  $service_dump,
  $find_days_old,
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
  '/backups/scripts/library.sh':
    ensure  => present,
    content => epp('profile/backup_scripts/library.epp',
    )
    ;
  '/backups/scripts/backups-daily.sh':
    ensure  => present,
    content => epp('profile/backup_scripts/backups-daily.epp',
    {
      'bucketlocation' => $bucketlocation
    }
    )
    ;
  '/backups/scripts/FirstService.sh':
    ensure  => present,
    content => epp('profile/backup_scripts/firstservice.epp',
    {
      'service_dump' => $service_dump,
      'finddaysold'  => $find_days_old,
    }
    )
    ;

}

$library = @("EOT")

    | EOT
}
