class anysync::coordinator::monitoring {
  include ::process_exporter
  process_exporter::include { "any-sync-coordinator":
    cfg => {
      "process_names" => [
        {
          "name" => "any-sync-coordinator",
          "comm" => ["any-sync-coordi"],
        }
      ]
    }
  }
  common::consul_cfg { "any-sync-coordinator": port => 8000 }
  collectd::cfg { "any-sync-coordinator": content => inline_template("LoadPlugin processes\n<Plugin processes>\n    ProcessMatch \"any-sync-coordinator\" \"/bin/any-sync-coordinator\"\n</Plugin>\n") }
}
