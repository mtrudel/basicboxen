working_directory ENV["UNICORN_WORKING_DIR"] if ENV["UNICORN_WORKING_DIR"]
listen ENV["UNICORN_LISTEN"] if ENV["UNICORN_LISTEN"]
worker_processes ENV["UNICORN_WORKERS"].to_i if ENV["UNICORN_WORKERS"]

timeout 30

preload_app true

before_fork do |server, worker|
  # Disconnect since the database connection will not carry over
  if defined? ActiveRecord::Base
    ActiveRecord::Base.connection.disconnect!
  end
end

after_fork do |server, worker|
  # Start up the database connection again in the worker
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
