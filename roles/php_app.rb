name "php_app"
description "php environment"

run_list(
  "recipe[php]",
  "recipe[composer]"
)
