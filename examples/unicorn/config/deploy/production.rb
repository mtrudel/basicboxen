set :stage, :production

set :rails_env, 'production'

set :public_hostname, 'example.com'

server 'example.com', user: 'deploy', roles: %w{web app db}
