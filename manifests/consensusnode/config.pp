class anysync::consensusnode::config (
  Hash $cfg,
  Hash $accounts,
  String $user,
  String $group,
  String $daemon_name,
) {
  $basedir = dirname($cfg['networkStorePath'])
  user { $user:
    ensure => present,
    shell => '/sbin/nologin',
    managehome => false,
  }
  -> group { $group:
    ensure => present,
  }
  -> file {
    "/etc/any-sync-consensusnode/":
      ensure => directory,
    ;
    "/etc/any-sync-consensusnode/config.yml":
      content => template("${module_name}/yaml.erb"),
      notify => Service["any-sync-consensusnode"],
    ;
    [
      $basedir,
      $cfg['networkStorePath'],
    ]:
      ensure => directory,
      owner => $user,
      group => $group,
    ;
  }
  -> syslog_ng::cfg { "any-sync-consensusnode": template => "t_short" }
  -> systemd::unit_file { "any-sync-consensusnode.service":
    content => template("${module_name}/service.erb"),
    enable => true,
    active => true,
  }
}