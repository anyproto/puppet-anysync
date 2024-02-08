class anysync::node::monitoring (
  Boolean $consul = $::anysync::monitoring,
  Boolean $collectd = $::anysync::monitoring,
) {
  if $consul {
    tools::consul_cfg { "any-sync-node": port => 8000 }
  }
  if $collectd {
    collectd::cfg { "any-sync-node": content => inline_template("LoadPlugin processes\n<Plugin processes>\n    ProcessMatch \"any-sync-node\" \"/bin/any-sync-node\"\n</Plugin>\n") }
  }
}
