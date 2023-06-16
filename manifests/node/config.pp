class anysync::node::config (
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
    "/etc/any-sync-node/config.yml":
      content => template("${module_name}/yaml.erb"),
      notify => Service["any-sync-node"],
    ;
    [
      $cfg['storage']['path'],
      $cfg['networkStorePath'],
    ]:
      ensure => directory,
      owner => $user,
      group => $group,
    ;
  }
  -> syslog_ng::cfg { "any-sync-node": template => "t_short" }
  -> systemd::unit_file { "any-sync-node.service":
    content => template("${module_name}/service.erb"),
    enable => true,
    active => true,
  }
}
