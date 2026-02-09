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
# @param limit_nofile
#   set limit nofile for daemon
# @param environments
#   set environments variables for daemon
#
class anysync::coordinator::config (
  Hash $cfg,
  Hash $network,
  Hash $accounts,
  String $user,
  String $group,
  String $daemon_name,
  Hash $syslog_ng = $::anysync::_syslog_ng,
  Variant[Integer,Boolean] $limit_nofile = $::anysync::limit_nofile,
  Hash $environments,
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
    "/etc/any-sync-coordinator/":
      ensure => directory,
    ;
    "/etc/any-sync-coordinator/config.yml":
      content => template("${module_name}/yaml.erb"),
      notify => Service["any-sync-coordinator"],
    ;
    # network.yml for any-sync-confapply
    # usage: any-sync-confapply -c /etc/any-sync-coordinator/config.yml -n /etc/any-sync-coordinator/network.yml -e
    "/etc/any-sync-coordinator/network.yml":
      content => template("${module_name}/network.yaml.erb"),
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
  if $syslog_ng['ensure'] {
    syslog_ng::cfg { "any-sync-coordinator": * => $syslog_ng }
  }
  systemd::unit_file { "any-sync-coordinator.service":
    content => template("${module_name}/service.erb"),
    enable => true,
    active => true,
  }
}
