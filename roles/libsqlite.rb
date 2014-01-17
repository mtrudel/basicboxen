name "libsqlite"
description "SQLite libraries"

run_list(
  "recipe[site-sqlite::install_sqlite_dev]",
)
