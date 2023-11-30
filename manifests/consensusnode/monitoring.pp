class anysync::consensusnode::monitoring {
  if $::anysync::monitoring {
    tools::consul_cfg { "any-sync-consensusnode": port => 8000 }
    collectd::cfg { "any-sync-consensusnode": content => inline_template("LoadPlugin processes\n<Plugin processes>\n    ProcessMatch \"any-sync-consensusnode\" \"/bin/any-sync-consensusnode\"\n</Plugin>\n") }
  }
}
