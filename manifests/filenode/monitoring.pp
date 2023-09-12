class anysync::filenode::monitoring {
  if $::anysync::monitoring {
    common::consul_cfg { "any-sync-filenode": port => 8000 }
    collectd::cfg { "any-sync-filenode": content => inline_template("LoadPlugin processes\n<Plugin processes>\n    ProcessMatch \"any-sync-filenode\" \"/bin/any-sync-filenode\"\n</Plugin>\n") }
  }
}
