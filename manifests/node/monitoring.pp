class anysync::node::monitoring {
  if $::anysync::monitoring {
    tools::consul_cfg { "any-sync-node": port => 8000 }
    collectd::cfg { "any-sync-node": content => inline_template("LoadPlugin processes\n<Plugin processes>\n    ProcessMatch \"any-sync-node\" \"/bin/any-sync-node\"\n</Plugin>\n") }
  }
}
