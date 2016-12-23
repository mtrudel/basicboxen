name "postgres"
description "Postgresql server"

run_list(
  "recipe[postgresql]",
  "recipe[postgresql::server]",
)

# Set postgres to do the following:
#  - only listen on a local domain socket
#  - accept connections based on the unix account name of the connecting user
#  - set postgres' password to nonsense, since it's never used
#
#  The intended use case of this approach is to bootstrap postgres users by
#  running the appropriate commands as the postgresql unix account, i.e.:
#
#  $ sudo su postgres -c 'createuser [options] <username>'
#  $ sudo su postgres -c 'createdb <dbname> -O <username>'
#
# This is only as secure as the OS's user system is; a reasonable assumption
# given that access to a users' account would almost always entail access to
# that users' database as well (by searching through application config files,
# etc). The benefit of this approach is that it greatly simplifies the
# connection parameters needed in any applications that run on this machine,
# since authentication is implicit. For example, a typical rails database.yml
# file for an app deployed to this environment would look like:
#
# ...
# production:
#   adapter: postgresql
#   database: dbname
#   pool: 5
#   timeout: 5000
#
# This approach ensures that no database secrets ever have to be stored
# anywhere, for the simple reason that no database secrets ever exist.
#
override_attributes(
  "postgresql" => {
    "assign_postgres_password" => false,
    "config" => {
      "listen_addresses" => 'localhost'
    },
    "pg_hba" => [{
      type: 'local',
      db: 'all',
      user: 'all',
      method: 'trust'
    }],
    "password" => {
      "postgres" => "md500000000000000000000000000000000"
    }
  }
)
