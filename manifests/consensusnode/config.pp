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
class anysync::consensusnode::config (
  Hash $cfg,
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
  if $syslog_ng['ensure'] {
    syslog_ng::cfg { "any-sync-consensusnode": * => $syslog_ng }
  }
  systemd::unit_file { "any-sync-consensusnode.service":
    content => template("${module_name}/service.erb"),
    enable => true,
    active => true,
  }
}
