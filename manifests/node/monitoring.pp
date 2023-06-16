class anysync::node::monitoring {
  include ::process_exporter
  process_exporter::include { "any-sync-node":
    cfg => {
      "process_names" => [
        {
          "name" => "any-sync-node",
          "comm" => ["any-sync-node"],
        }
      ]
    }
  }
  common::consul_cfg { "any-sync-node": port => 8000 }
  collectd::cfg { $caller_module_name: content => inline_template("LoadPlugin processes\n<Plugin processes>\n    ProcessMatch \"any-sync-node\" \"/bin/any-sync-node\"\n</Plugin>\n") }
}
