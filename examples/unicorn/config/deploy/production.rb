set :stage, :production

set :rails_env, 'production'

server 'example.com', user: 'deploy', roles: %w{web app db}
