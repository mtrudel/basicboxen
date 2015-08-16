name "proxy"
description "Reverse proxy server"

run_list(
  "recipe[nginx]",
)

# define openssl_source below because the recipe defaults to an earlier version
override_attributes(
  "nginx" => {
    "default_site_enabled" => false,
    "openssl_source" => {
      "version" => "1.0.2d"
    }
  }
)
