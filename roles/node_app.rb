name "node_app"
description "nodejs environment"

run_list(
  "recipe[build-essential]",
  "recipe[nodejs]",
)
