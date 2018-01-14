class nrpe::service (
  $service_enable = $nrpe::service_enable,
  $service_ensure = $nrpe::service_ensure,
  $service_manage = $nrpe::service_manage,
  $nrpe_service   = $nrpe::nrpe_service,
) inherits nrpe {

  if ! ($service_ensure in [ 'running', 'stopped' ]) {
    fail('service_ensure parameter must be running or stopped')
  }

  if $service_manage == true {
    service { $nrpe_service:
      ensure     => $service_ensure,
      enable     => $service_enable,
      hasstatus  => true,
      hasrestart => true,
    }
  }

}
