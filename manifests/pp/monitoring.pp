class anysync::pp::monitoring (
  Boolean $consul = $::anysync::monitoring,
  Boolean $collectd = $::anysync::monitoring,
) {
  if $consul {
    common::consul_cfg { "any-pp-node": port => 8000 }
  }
  if $collectd {
    collectd::cfg { "any-pp-node": content => inline_template("LoadPlugin processes\n<Plugin processes>\n    ProcessMatch \"any-pp-node\" \"/bin/any-pp-node\"\n</Plugin>\n") }
  }
}
