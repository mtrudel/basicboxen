name "ruby_app"
description "ruby environment"

run_list(
  "recipe[build-essential]",
  "recipe[rbenv]",
  "recipe[rbenv::ruby_build]",
  "recipe[site-ruby::install_ruby]"
)
