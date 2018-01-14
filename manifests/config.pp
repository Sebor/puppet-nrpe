class nrpe::config (
  $conf_file          = $nrpe::conf_file,
  $configs_path       = $nrpe::configs_path,
  $plugins_path       = $nrpe::plugins_path,
  $config_template    = $nrpe::config_template,
  $nag_servers        = $nrpe::nag_servers,
) inherits nrpe {

  file { $conf_file:
    ensure  => file,
    backup  => true,
    mode    => '0644',
    content => template($config_template),
  }

  file { $configs_path:
    ensure       => directory,
    recurse      => remote,
    sourceselect => all,
    source       => "puppet:///modules/nrpe/nrpe.d/${osfamily}/",
  }

  file { $plugins_path:
    ensure       => directory,
    recurse      => remote,
    sourceselect => all,
    source       => 'puppet:///modules/nrpe/plugins/',
    mode         => '0755',
  }

}
