class anysync (
  Boolean $enable_node,
  Boolean $enable_filenode,
  Boolean $enable_coordinator,
){
  if $enable_node {
    class { "${module_name}::node::install": }
    -> class { "${module_name}::node::config": }
    -> class { "${module_name}::node::service": }
    -> class { "${module_name}::node::monitoring": }
  }
  if $enable_filenode {
    class { "${module_name}::filenode::install": }
    -> class { "${module_name}::filenode::config": }
    -> class { "${module_name}::filenode::service": }
    -> class { "${module_name}::filenode::monitoring": }
  }
  if $enable_coordinator {
    class { "${module_name}::coordinator::install": }
    -> class { "${module_name}::coordinator::config": }
    -> class { "${module_name}::coordinator::service": }
    -> class { "${module_name}::coordinator::monitoring": }
  }
}
