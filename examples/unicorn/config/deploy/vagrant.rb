set :stage, :vagrant

set :rails_env, 'development'
set :bundle_without, 'production'

server '192.168.50.4', user: 'deploy', roles: %w{web app}
set :public_hostname, '192.168.50.4'

