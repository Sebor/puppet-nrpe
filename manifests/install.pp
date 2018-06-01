class nrpe::install (
  $package_ensure = $nrpe::params::package_ensure,
  $nrpe_pkgs      = $nrpe::params::nrpe_pkgs,
) inherits nrpe {

  package { $nrpe_pkgs:
    ensure => $package_ensure,
  }

}
