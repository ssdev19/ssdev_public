# Base profile for Windows OS
# @param ipmi
#  If `true`, include ipmi
# @param packages
#  If `true`, include ipmi
# @param timezone
#  configure timezone
class profile::base_windows (
  String $timezone,
  Boolean $ipmi  = false,
  Optional[Array[String]]     $packages = undef,
) {
  include chocolatey # Needed for just about most things for Windows.

  package { 'windows_exporter':
    ensure => '0.24.0',
    source => 'https://github.com/prometheus-community/windows_exporter/releases/download/v0.24.0/windows_exporter-0.24.0-amd64.msi'
  }
  package { 'Notepad++ (64-bit x64)':
    ensure          => installed,
    source          => 'http://wsus.lsst.org/puppetfiles/notepad/Notepad7.9.1.msi',
    install_options => '/quiet',
  }
  class { 'timezone_win':
    timezone => $timezone,
  }
  package { 'NXLog-CE':
    ensure => '3.2.2329',
    source => 'http://wsus.lsst.org/puppetfiles/nxlog/nxlog-ce-3.2.2329.msi',
  }
  file { 'C:/Program Files/nxlog/conf/nxlog.conf':
    ensure => file,
    source => 'http://wsus.lsst.org/puppetfiles/nxlog/nxlog3.2.2329.conf',
    notify => Service['nxlog'],
  }
  service { 'nxlog':
    ensure => 'running',
    enable => true,
  }

# Install ipmi
  # if $ipmi {
  #   package { 'IPMIView':
  #       ensure => installed,
  #       source => "e:\\temp\\IPMIView.exe",
  #       install_options => ['n'], # ,'INSTALLDIR=C:\\Program Files\\Supermicro\\IPMIView'
  #   }
  # Start service if it has stopped or crashed.
  service { 'windows_exporter':
    ensure => running,
  }
}
