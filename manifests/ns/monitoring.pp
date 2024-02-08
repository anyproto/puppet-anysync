class anysync::ns::monitoring (
  Boolean $consul = $::anysync::monitoring,
  Boolean $collectd = $::anysync::monitoring,
) {
  if $consul {
    tools::consul_cfg { "any-ns-node": port => 8000 }
  }
  if $collectd {
    collectd::cfg { "any-ns-node": content => inline_template("LoadPlugin processes\n<Plugin processes>\n    ProcessMatch \"any-ns-node\" \"/bin/any-ns-node\"\n</Plugin>\n") }
  }
}
