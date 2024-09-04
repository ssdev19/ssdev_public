# jira
class profile::jira {
  include jira
  file {
    '/opt/atlassian':
      ensure => directory,
      # mode   => '0700',
      ;
    '/opt/atlassian/application-data':
      ensure => directory,
      # mode   => '0600',
      ;
  }
}
