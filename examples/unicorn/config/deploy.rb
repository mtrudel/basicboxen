require 'bundler/capistrano'

# Set this to a shorthand name for the application
set :application, "example"

# Set this to the remote git repo where your application's code is
set :repository,  "git@github.com:user/project.git"

# Set this to the name of the basic boxen server you've built
set :server_name, "example.com"

# Set this to the number of concurrent unicorn processes you want to have
# running your site. For development / staging purposes, 4 is probably plenty
set :unicorn_workers, 4

# You probably don't need change anything below here, at least to get started

role :web, "#{server_name}"
role :app, "#{server_name}"
role :db,  "#{server_name}", :primary => true

set :user, "deploy"
set :deploy_to, "/home/deploy/#{application}"

set :unicorn_socket, "/tmp/unicorn.#{application}.sock"

set :deploy_via, :remote_cache

set :ssh_options, { :forward_agent => true }
set :use_sudo, true

default_run_options[:pty] = true
set :default_environment, {
  'PATH' => "/opt/rbenv/shims/:$PATH"
}

after "deploy:setup", "db:create_user"
after "deploy:setup", "db:create_database"
after "deploy:setup", "nginx:setup_proxy"

after "deploy:finalize_update", "deploy:setup_environment_vars"
after "deploy:update", "deploy:setup_upstart"

namespace :db do
  task :create_user do
    run "#{sudo} su postgres -c 'createuser --no-createdb --no-superuser --no-createrole --no-inherit #{user}' || true"
  end

  task :create_database do
    run "#{sudo} su postgres -c 'createdb #{application} -O #{user}' || true"
  end
end

namespace :nginx do
  task :setup_proxy do
    proxy_file = ERB.new(File.read(File.join(File.dirname(__FILE__), "templates", "nginx-proxy"))).result(binding)
    put proxy_file, "/tmp/#{application}", :via => :scp
    run "#{sudo} mv /tmp/#{application} /etc/nginx/sites-enabled/#{application}"
    run "#{sudo} chown root:root /etc/nginx/sites-enabled/#{application}"
    run "#{sudo} chmod 644 /etc/nginx/sites-enabled/#{application}"
    run "#{sudo} service nginx reload"
  end
end

namespace :deploy do
  %w{stop start restart}.each do |action|
    task action do
      run "#{sudo} service #{application} #{action}"
    end
  end

  task :setup_environment_vars do
    production_environment = <<-EOF.gsub /^\s*/, ''
      RACK_ENV=#{rails_env}
      UNICORN_WORKING_DIR=#{current_path}
      UNICORN_LISTEN=#{unicorn_socket}
      UNICORN_WORKERS=#{unicorn_workers}
    EOF
    put production_environment, File.join(latest_release, '.env'), :via => :scp
  end

  task :setup_upstart do
    run "cd #{current_path}; #{sudo} bundle exec foreman export upstart -a #{application} -d #{current_path} -u #{user} /etc/init"
  end
end
