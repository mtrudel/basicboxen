name "redis"
description "Redis Server"

run_list(
  "recipe[redisio::install]",
  "recipe[redisio::enable]"
)

override_attributes(
  "redisio" => {
    'servers' => [
      {'name' => 'master', 'port' => 6379, 'address' => '127.0.0.1'},
    ]
  }
)
