class anysync::coordinator::config (
  Hash $cfg,
  Hash $accounts,
  String $user,
  String $group,
  String $daemon_name,
) {
  user { $user:
    ensure => present,
    shell => '/sbin/nologin',
    managehome => false,
  }
  -> group { $group:
    ensure => present,
  }
  -> file {
    "/etc/any-sync-coordinator/config.yml":
      content => template("any_sync_node/yaml.erb"),
      notify => Service["any-sync-coordinator"],
    ;
    [
      $cfg['networkStorePath'],
    ]:
      ensure => directory,
      owner => $user,
      group => $group,
    ;
  }
  -> syslog_ng::cfg { "any-sync-coordinator": template => "t_short" }
  -> systemd::unit_file { "any-sync-coordinator.service":
    content => template("${module_name}/service.erb"),
    enable => true,
    active => true,
  }
}
