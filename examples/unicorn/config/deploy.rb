# config valid only for Capistrano 3.1
lock '3.1.0'

# Set this to a shorthand name for the application
set :application, 'example'

# Set this to the remote git repo where your application's code is
set :repo_url, 'git@github.com:example/example.git'

# Set this to where you want the project deployed
set :deploy_to, "/home/deploy/#{fetch(:application)}"

set :rbenv_type, :system
set :rbenv_ruby, '2.1.0'
set :rbenv_custom_path, '/opt/rbenv'

# Set this to the number of concurrent unicorn processes you want to have
# running your site. For development / staging purposes, 4 is probably plenty
set :unicorn_workers, 4
set :unicorn_socket, "/tmp/unicorn.#{fetch(:application)}.sock"

namespace :deploy do
  %w{stop start restart}.each do |action|
    desc "#{action} application"
    task action do
      on roles(:app), in: :sequence, wait: 5 do
        as :root do
          execute :service, fetch(:application), action
        end
      end
    end
  end

  after :publishing, :restart

  task :setup_environment_vars => :'deploy:updated' do
    on roles(:app), in: :sequence, wait: 5 do
      dotenv = ERB.new(File.read(File.join(File.dirname(__FILE__), "templates", "dotenv"))).result(binding)
      upload! StringIO.new(dotenv), File.join(release_path, '.env')
    end
  end

  before :restart, :setup_environment_vars

  task :setup_upstart => "bundler:install" do
    on roles(:app) do |host|
      within current_path do
        as :root do
          # rbenv/shims isn't in root's path, so we need to explicitly path it
          # since command maps are wonky within as() blocks
          execute "#{fetch(:rbenv_custom_path)}/shims/bundle", :exec, :foreman, :export, :upstart, :'-f', 'Procfile', :'-a', fetch(:application), :'-d', current_path, :'-u', host.user, :'/etc/init'
        end
      end
    end
  end

  before :restart, :setup_upstart
end

namespace :db do
  desc 'Create a database for the app'
  task :create_database do
    on roles(:db) do |host|
      as :postgres do
        execute :createdb, fetch(:application), :'-O', host.user, :raise_on_non_zero_exit => false
      end
    end
  end

  before 'deploy', 'db:create_database'

  desc 'Create a database user for the app'
  task :create_user do
    on roles(:db) do |host|
      as :postgres do
        execute :createuser, :'--no-createdb', :'--no-superuser', :'--no-createrole', :'--no-inherit', host.user, :raise_on_non_zero_exit => false
      end
    end
  end

  before 'db:create_database', 'db:create_user'
end

namespace :nginx do
  desc 'Set up nginx config file'
  task :setup_proxy do
    on roles(:app) do |host|
      execute :mkdir, "-p", "#{fetch(:tmp_dir)}/#{fetch(:application)}/"
      proxy_file = ERB.new(File.read(File.join(File.dirname(__FILE__), "templates", "nginx-proxy"))).result(binding)
      upload! StringIO.new(proxy_file), "#{fetch(:tmp_dir)}/#{fetch(:application)}/nginx-config"
      as :root do
        execute :mv, "#{fetch(:tmp_dir)}/#{fetch(:application)}/nginx-config", "/etc/nginx/sites-enabled/#{fetch(:application)}"
        execute :chown, :'root:root', "/etc/nginx/sites-enabled/#{fetch(:application)}"
        execute :chmod, :'644', "/etc/nginx/sites-enabled/#{fetch(:application)}"
        execute :service, :nginx, :reload
      end
    end
  end

  before 'deploy', 'nginx:setup_proxy'
end
