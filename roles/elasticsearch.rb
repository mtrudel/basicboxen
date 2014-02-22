name "elasticsearch"
description "Elasticsearch Server"

run_list(
  "recipe[java]",
  "recipe[elasticsearch]"
)

override_attributes(
  "java" => {
    "install_flavor" => "openjdk",
    "jdk_version" => "7"
  },
  "elasticsearch" => {
    "cluster" => { "name" => "elasticsearch_chef" },
    "network" => { "bind_host" => "localhost" },
    "allocated_memory" => "64m"
  }
)
