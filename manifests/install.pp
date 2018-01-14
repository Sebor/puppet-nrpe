class nrpe::install (
  $package_ensure = $nrpe::package_ensure,
  $nrpe_pkgs      = $nrpe::nrpe_pkgs,
) inherits nrpe {

  package { $nrpe_pkgs:
    ensure => $package_ensure,
  }

}
