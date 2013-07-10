node['users'].each do |user|
  user_account user['username'] do
    comment   user['comment']
    ssh_keys  user['ssh_keys']
  end
end
