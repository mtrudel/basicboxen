name "mongodb"
description "Mongodb Server"

run_list(
  "recipe[mongodb-10gen::single]",
)

override_attributes(
)
