# Base profile for Windows OS
class profile::base_windows (
  Boolean $ipmi  = false,
) {

  include chocolatey # Needed for just about most things for Windows.
  package { 'windows_exporter':
      ensure => '0.19.0',
      source => 'https://github.com/prometheus-community/windows_exporter/releases/download/v0.19.0/windows_exporter-0.19.0-amd64.msi'
  }
  package { 'Notepad++ (64-bit x64)':
      ensure => installed,
      source => 'http://wsus.lsst.org/puppetfiles/notepad/Notepad7.9.1.msi',
      install_options => '/quiet',
  }
# Install ipmi
  if $ipmi {
    package { 'IPMIView':
        ensure => installed,
        source => "e:\\temp\\IPMIView_2.21.0_build.221118_Windows.exe",
        install_options => ['/VERYSILENT'],
    }
  }  # package { 'Notepad++':
  #     ensure          => '8.45',
  #     source          => 'http://wsus.lsst.org/puppetfiles/notepad/npp.Installer.exe',
  #     install_options => ['/VERYSILENT'],
  # }
  # Start service if it has stopped or crashed.
  service { 'windows_exporter':
    ensure => running,
  }
}
