class nrpe::params {

  $package_ensure  = 'present'
  $service_enable  = true
  $service_ensure  = 'running'
  $service_manage  = true
  $conf_file       = ['/etc/nagios/nrpe.cfg']
  $config_template = 'nrpe/nrpe.cfg.erb'
  $nag_servers     = '127.0.0.1,172.16.1.11,172.16.1.115,172.16.1.117,10.216.41.111'

  case $::osfamily {
    'Debian': {
      $nrpe_pkgs       = ['wget', 'sysstat', 'snmp', 'nagios-nrpe-server', 'nagios-plugins-basic', 'nagios-nrpe-plugin', 'libnet-snmp-perl']
      $configs_path    = '/etc/nagios/nrpe.d/'
      $plugins_path    = '/usr/lib/nagios/plugins/'
      $nrpe_service    = 'nagios-nrpe-server'
      $nrpe_user       = 'nagios'
      $nrpe_pidf       = '/var/run/nagios/nrpe.pid'
    }
    'RedHat': {
      $nrpe_pkgs       = ['wget', 'sysstat', 'net-snmp', 'nrpe', 'nagios-plugins-all']
      $configs_path    = '/etc/nrpe.d/'
      $plugins_path    = '/usr/lib64/nagios/plugins/'
      $nrpe_service    = 'nrpe'
      $nrpe_user       = 'nrpe'
      $nrpe_pidf       = '/var/run/nrpe/nrpe.pid'
    }
  }

}
