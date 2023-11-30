class anysync::consensusnode::monitoring (
  Boolean $consul = $::anysync::monitoring,
  Boolean $collectd = $::anysync::monitoring,
) {
  if $consul {
    tools::consul_cfg { "any-sync-consensusnode": port => 8000 }
  }
  if $collectd {
    collectd::cfg { "any-sync-consensusnode": content => inline_template("LoadPlugin processes\n<Plugin processes>\n    ProcessMatch \"any-sync-consensusnode\" \"/bin/any-sync-consensusnode\"\n</Plugin>\n") }
  }
}
