# @param cfg
#   Defines config for daemon
# @param accounts
#   Defines "account" settings for all nodes (see "any_sync_accounts" in README.md)
# @param user
#   Defines user for daemon files and process
# @param group
#   Defines group for daemon files and process
# @param daemon_name
#   Defines daemon name
# @param syslog_ng
#   enable or disable syslog-ng configuration for logging
#
class anysync::ns::config (
  Hash $cfg,
  Hash $accounts,
  String $user,
  String $group,
  String $daemon_name,
  Boolean $syslog_ng = $::anysync::syslog_ng,
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
    "/etc/any-ns-node/":
      ensure => directory,
    ;
    "/etc/any-ns-node/config.yml":
      content => template("${module_name}/yaml.erb"),
      notify => Service["any-ns-node"],
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
  if $syslog_ng {
    syslog_ng::cfg { "any-ns-node": template => "t_short" }
  }
  systemd::unit_file { "any-ns-node.service":
    content => template("${module_name}/service.erb"),
    enable => true,
    active => true,
  }
}
