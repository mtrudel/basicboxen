name "proxy"
description "Reverse proxy server"

run_list(
  "recipe[nginx]",
)

override_attributes(
  "nginx" => {
    "default_site_enabled" => false,
    "openssl_source" => {
      "version" => "1.0.1h"
    }
  }
)
