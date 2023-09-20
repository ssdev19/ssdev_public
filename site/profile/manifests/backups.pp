# Backups of files and DBs per Iain's scripts
class profile::backups {

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
    ensure  => file,
    content => $library,

    ;
  }

$library = @("EOT")

  function GetHello() {
  echo "Hello World"
  }

  # Pause it function to be able to read or perform manual work
  function pauseit(){
  read -p "$*"
  }

  function ResetReport() {
  Report2Update="$1"
  > ${Report2Update}
  }

  function GetTime() {
  echo `date +%Y%m%d%H%M%S`
  }

  ReportStatement() {
  Report2Update="$1"
  ReportStatement="$2"
  echo ${ReportStatement} >> ${Report2Update}
  }

  FindOldBackupSet() {
  StartFindHere="$1"
  FindDaysOld="$2"
  echo "This is the location ${StartFindHere}"
  echo " "
  echo "This is the number of days old ${FindDaysOld}"
  echo " "
  echo "This is the command "
  echo " "
  echo "find ${StartFindHere} -type f -mtime ${FindDaysOld}"
  find ${StartFindHere} -type f -mtime ${FindDaysOld} -delete
  }


  Sync2Cloud() {
  AWSCommand=$1
  BucketLocation=$2
  SyncSource=$3
  echo "This is the bucket ${BucketLocation}"
  echo " "
  # Run the command
  ${AWSCommand} s3 sync ${SyncSource} s3://${BucketLocation} --no-progress
  }

  SendReport() {
  Report2Send="$1"
  Subject2Send="$2"
  Recipient2Send="$3"
  echo ${Report2Send}
  echo ${Subject2Send}
  echo ${Recipient2Send}
  cat ${Report2Send}|mail igoodenow@lsst.org
  }

    | EOT
}
