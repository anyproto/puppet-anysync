# @summary configures the anysync module
#
# @param node
#   enable or disable "tree node" daemon
# @param filenode
#   enable or disable "filenode" daemon
# @param coordinator
#   enable or disable "coordinator" daemon
# @param consensusnode
#   enable or disable "consensusnode" daemon
# @param syslog_ng
#   enable or disable syslog-ng configuration for logging
# @param monitoring
#   enable or disable monitoring manifests
#
class anysync (
  Boolean $node,
  Boolean $filenode,
  Boolean $coordinator,
  Boolean $consensusnode,
  Variant[Hash,Boolean] $syslog_ng,
  Boolean $monitoring,
  Boolean $ns,
){
  if $syslog_ng =~ Hash {
    $_syslog_ng = $syslog_ng
  } else {
    $_syslog_ng = {
      ensure => $syslog_ng,
      template => "t_short",
    }
  }

  if $node {
    class { "${module_name}::node::install": }
    -> class { "${module_name}::node::config": }
    -> class { "${module_name}::node::service": }
    -> class { "${module_name}::node::monitoring": }
  }
  if $filenode {
    class { "${module_name}::filenode::install": }
    -> class { "${module_name}::filenode::config": }
    -> class { "${module_name}::filenode::service": }
    -> class { "${module_name}::filenode::monitoring": }
  }
  if $coordinator {
    class { "${module_name}::coordinator::install": }
    -> class { "${module_name}::coordinator::config": }
    -> class { "${module_name}::coordinator::service": }
    -> class { "${module_name}::coordinator::monitoring": }
  }
  if $consensusnode {
    class { "${module_name}::consensusnode::install": }
    -> class { "${module_name}::consensusnode::config": }
    -> class { "${module_name}::consensusnode::service": }
    -> class { "${module_name}::consensusnode::monitoring": }
  }
  if $ns {
    class { "${module_name}::ns::install": }
    -> class { "${module_name}::ns::config": }
    -> class { "${module_name}::ns::service": }
    -> class { "${module_name}::ns::monitoring": }
  }
}
