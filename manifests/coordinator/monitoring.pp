class anysync::coordinator::monitoring {
  if $::anysync::monitoring {
    common::consul_cfg { "any-sync-coordinator": port => 8000 }
    collectd::cfg { "any-sync-coordinator": content => inline_template("LoadPlugin processes\n<Plugin processes>\n    ProcessMatch \"any-sync-coordinator\" \"/bin/any-sync-coordinator\"\n</Plugin>\n") }
  }
}
