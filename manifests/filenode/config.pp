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
# @param aws_credentials
#   Defines credentials for access to s3
# @param syslog_ng
#   enable or disable syslog-ng configuration for logging
# @param limit_nofile
#   set limit nofile for daemon
# @param environments
#   set environments variables for daemon
#
class anysync::filenode::config (
  Hash $cfg,
  Hash $accounts,
  String $user,
  String $group,
  String $daemon_name,
  Hash $aws_credentials,
  Hash $syslog_ng = $::anysync::_syslog_ng,
  Variant[Integer,Boolean] $limit_nofile = $::anysync::limit_nofile,
  Hash $environments,
) {
  $basedir = dirname($cfg['networkStorePath'])
  user { $user:
    ensure => present,
    shell => '/sbin/nologin',
    managehome => true,
  }
  -> group { $group:
    ensure => present,
  }
  -> file {
    "/etc/any-sync-filenode/":
      ensure => directory,
    ;
    "/etc/any-sync-filenode/config.yml":
      content => template("${module_name}/yaml.erb"),
      notify => Service["any-sync-filenode"],
    ;
    [
      $basedir,
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

  if $syslog_ng['ensure'] {
    syslog_ng::cfg { "any-sync-filenode": * => $syslog_ng }
  }
  systemd::unit_file { "any-sync-filenode.service":
    content => template("${module_name}/service.erb"),
    enable => true,
    active => true,
  }
}
