name "mongodb"
description "Mongodb Server"

run_list(
  "recipe[mongodb::10gen_repo]",
  "recipe[mongodb]"
)

override_attributes(
  "mongodb" => {
    "config" => {
      "bind_ip" => "127.0.0.1"
    }
  }
)
