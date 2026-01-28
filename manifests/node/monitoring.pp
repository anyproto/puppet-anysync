class anysync::node::monitoring (
  Boolean $consul = $::anysync::monitoring,
  Boolean $collectd = $::anysync::monitoring,
) {
  if $consul {
    tools::consul_cfg { "any-sync-node": port => 8000 }
  }
  if $collectd {
    $user = $::anysync::node::config::user

    collectd::bin { "anysyncStorageStats.sh": content => template("$caller_module_name/collectd/anysyncStorageStats.sh.erb") }
    collectd::cfg {
      "any-sync-node": content => inline_template("LoadPlugin processes\n<Plugin processes>\n    ProcessMatch \"any-sync-node\" \"/bin/any-sync-node\"\n</Plugin>\n");
      "anysyncStorageStats": content => template("$caller_module_name/collectd/anysyncStorageStats.conf");
    }
  }
}
