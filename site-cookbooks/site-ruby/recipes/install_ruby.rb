rbenv_ruby node[:site_ruby][:version] do
  global true
end

rbenv_gem "bundler" do
  ruby_version node[:site_ruby][:version]
end
