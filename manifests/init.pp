class nrpe (
  $conf_file          = $nrpe::params::conf_file,
  $config_template    = $nrpe::params::config_template,
  $package_ensure     = $nrpe::params::package_ensure,
  $nrpe_pkgs          = $nrpe::params::nrpe_pkgs,
  $nag_servers        = $nrpe::params::nag_servers,
  $service_enable     = $nrpe::params::service_enable,
  $service_ensure     = $nrpe::params::service_ensure,
  $service_manage     = $nrpe::params::service_manage,
  $nrpe_service       = $nrpe::params::nrpe_service,
) inherits nrpe::params {

  include '::nrpe::install'
  include '::nrpe::config'
  include '::nrpe::service'

  # Anchor this as per #8140 - this ensures that classes won't float off and
  # mess everything up.  You can read about this at:
  # http://docs.puppetlabs.com/puppet/2.7/reference/lang_containment.html#known-issues
  anchor { 'nrpe::begin': }
  anchor { 'nrpe::end': }

  Anchor['nrpe::begin'] -> Class['::nrpe::install'] -> Class['::nrpe::config']
    ~> Class['::nrpe::service'] -> Anchor['nrpe::end']

}
