class anysync::filenode::monitoring (
  Boolean $consul = $::anysync::monitoring,
  Boolean $collectd = $::anysync::monitoring,
) {
  if $consul {
    tools::consul_cfg { "any-sync-filenode": port => 8000 }
  }
  if $collectd {
    collectd::cfg { "any-sync-filenode": content => inline_template("LoadPlugin processes\n<Plugin processes>\n    ProcessMatch \"any-sync-filenode\" \"/bin/any-sync-filenode\"\n</Plugin>\n") }
  }
}
