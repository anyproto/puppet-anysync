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
class anysync::node::config (
  Hash $cfg,
  Hash $accounts,
  String $user,
  String $group,
  Variant[Integer,Boolean] $uid,
  Variant[Integer,Boolean] $gid,
  String $daemon_name,
  Hash $syslog_ng = $::anysync::_syslog_ng,
  Boolean $create_storage_path_dir,
  Variant[Integer,Boolean] $limit_nofile = $::anysync::limit_nofile,
) {
  $basedir = dirname($cfg['networkStorePath'])
  user { $user:
    ensure => present,
    shell => '/sbin/nologin',
    managehome => false,
    uid => $uid,
  }
  -> group { $group:
    ensure => present,
    gid => $gid,
  }
  -> file {
    "/etc/any-sync-node/":
      ensure => directory,
    ;
    "/etc/any-sync-node/config.yml":
      content => template("${module_name}/yaml.erb"),
      notify => Service["any-sync-node"],
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
  if $create_storage_path_dir {
    file {
      $cfg['storage']['path']:
        ensure => directory,
        owner => $user,
        group => $group,
      ;
    }
    if has_key($cfg['storage'],'anyStorePath') {
      file {
        $cfg['storage']['anyStorePath']:
          ensure => directory,
          owner => $user,
          group => $group,
        ;
      }
    }
  }
  if $syslog_ng['ensure'] {
    syslog_ng::cfg { "any-sync-node": * => $syslog_ng }
  }
  systemd::unit_file { "any-sync-node.service":
    content => template("${module_name}/service.erb"),
    enable => true,
    active => true,
  }
}
