name "baseline"
description "Universal Server Baseline"

run_list(
  "recipe[apt]",
  "recipe[logrotate]",
  "recipe[openssh]",
  "recipe[postfix]",
  "recipe[postfix::aliases]",
  "recipe[site-user::users]",
  "recipe[site-swap::swapon]",
  "recipe[sudo]",
  "recipe[unattended-upgrades]",
  "recipe[vim]",
  "recipe[git]"
)

override_attributes(
  "openssh" => {
    "server" => {
      "password_authentication" => "no",
      "permit_root_login" => "no"
    }
  },
  "unattended-upgrades" => {
    "allowed_origins" => {
      "security" => true,
      "updates" => true,
      "proposed" => false,
      "backports" => false
    },
    "remove_unused_dependencies" => true,
    "automatic_reboot" => true
  }
)
