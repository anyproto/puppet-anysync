class anysync::filenode::monitoring {
  include ::process_exporter
  process_exporter::include { "any-sync-filenode":
    cfg => {
      "process_names" => [
        {
          "name" => "any-sync-filenode",
          "comm" => ["any-sync-fileno"],
        }
      ]
    }
  }
  common::consul_cfg { "any-sync-filenode": port => 8000 }
  collectd::cfg { $caller_module_name: content => inline_template("LoadPlugin processes\n<Plugin processes>\n    ProcessMatch \"any-sync-filenode\" \"/bin/any-sync-filenode\"\n</Plugin>\n") }
}
