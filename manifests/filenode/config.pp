class anysync::filenode::config (
  Hash $cfg,
  Hash $accounts,
  String $user,
  String $group,
  String $daemon_name,
  Hash $aws_credentials,
) {
  user { $user:
    ensure => present,
    shell => '/sbin/nologin',
    managehome => true,
  }
  -> group { $group:
    ensure => present,
  }
  -> file {
    "/etc/any-sync-filenode/config.yml":
      content => template("${module_name}/yaml.erb"),
      notify => Service["any-sync-filenode"],
    ;
    [
      $cfg['networkStorePath'],
      "/home/$user/.aws/",
    ]:
      ensure => directory,
      owner => $user,
      group => $group,
    ;
  }

  $aws_credentials.each |$section, $settings| {
    $settings.each |$setting, $value| {
      ini_setting { "/home/$user/.aws/credentials_${section}-${setting}":
        ensure  => $value == undef ? { true => 'absent', default => 'present' },
        section => $section,
        setting => $setting,
        value   => $value,
        path    => "/home/$user/.aws/credentials",
        notify  => Service["any-sync-filenode"],
        require => File["/home/$user/.aws/"],
      }
    }
  }

  syslog_ng::cfg { "any-sync-filenode":
    require => File["/etc/any-sync-filenode/config.yml"],
    template => "t_short",
  }
  -> systemd::unit_file { "any-sync-filenode.service":
    content => template("${module_name}/service.erb"),
    enable => true,
    active => true,
  }
}
