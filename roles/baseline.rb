name "baseline"
description "Universal Server Baseline"

run_list(
  "recipe[apt]",
  "recipe[logrotate]",
  "recipe[ntp]",
  "recipe[openssh]",
  "recipe[postfix]",
  "recipe[postfix::aliases]",
  "recipe[site-user::users]",
  "recipe[sudo]",
  "recipe[unattended_upgrades]",
  "recipe[vim]",
)

override_attributes(
  "openssh" => {
    "server" => {
      "password_authentication" => "no",
      "permit_root_login" => "no"
    }
  },
)
