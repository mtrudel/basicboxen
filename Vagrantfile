VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # box basics
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # networking
  config.vm.network :private_network, ip: "192.168.50.4"

  # provisioning
  config.omnibus.chef_version = :latest
  config.berkshelf.berksfile_path = 'Berksfile'
  config.berkshelf.enabled = true
  config.vm.provision :chef_solo do |chef|
    chef.roles_path = "roles"
    chef.json = {
      "users" => [
        { "username" => "deploy",
          "comment" => "Deploy user",
          "ssh_keys" => ["ssh-dss AABBCCDDEEFF.....AABBCCDDEEFF optionalemail@example.com"]
        }
      ],
      "authorization" => {
        "sudo" => { "users" => ["deploy"], "passwordless" => true }
      }
    }
    chef.add_role("baseline")
    chef.add_role("elasticsearch")
    chef.add_role("mongodb")
    chef.add_role("proxy")
    chef.add_role("ruby_app")
    chef.add_role("libsqlite")
  end
end
