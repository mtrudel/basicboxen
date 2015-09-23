name "wordpress"
description "Wordpress configs (mainly MySQL)"

run_list(
  "recipe[php-fpm]",
  "recipe[site-wordpress::install_mysql]",
)
