class anysync::coordinator::monitoring (
  Boolean $consul = $::anysync::monitoring,
  Boolean $collectd = $::anysync::monitoring,
) {
  if $consul {
    tools::consul_cfg { "any-sync-coordinator": port => 8000 }
  }
  if $collectd {
    collectd::cfg { "any-sync-coordinator": content => inline_template("LoadPlugin processes\n<Plugin processes>\n    ProcessMatch \"any-sync-coordinator\" \"/bin/any-sync-coordinator\"\n</Plugin>\n") }
  }
}
