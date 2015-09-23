package 'php5-mysql'

mysql_service 'wordpress' do
  bind_address '127.0.0.1'
  initial_root_password 'changeme'
  action [:create, :start]
end
