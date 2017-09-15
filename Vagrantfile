# -*- mode: ruby -*-
# vi: set ft=ruby :


PROJECT_ROOT=`git rev-parse --show-toplevel`.strip
ANSIBLE_ROOT="#{PROJECT_ROOT}/ansible"

require 'fileutils'
require 'yaml'

INVENTORY_PATH = File.join(File.dirname(__FILE__), "inventory.yaml")
ANSIBLE_SETUP_PATH = File.join(File.dirname(__FILE__), "ansible.rb")

inventory_yaml = open(INVENTORY_PATH).read
nodes = YAML.load(inventory_yaml)['nodes']


# defaults
default_cpus              = 1
default_memory            = 1024


Vagrant.configure("2") do |config|
  nodes.each do |node|
    config.vm.define node['tags']['name'] do |machine|
      # machine.vbguest.auto_update = false
      machine.vm.box = node["box"]
      machine.vm.hostname = node['tags']['name']
      machine.vm.network :private_network, :ip => node['private_ip']
      # machine.vm.box_url = box_url + node["box"] + ".box"
      #machine.vm.network "private_network", type: "dhcp"


      if defined?(node["sync_folder"]) && (node["sync_folder"] != nil)
        machine.vm.synced_folder node["sync_folder"]["host_dir"], node["sync_folder"]["guest_dir"]
      end


      if defined?(node["ports"]) && (node["ports"] != nil)
        node["ports"].each do |port|
          port.each do |host, guest|
            machine.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
          end
        end
      end


      machine.vm.provider :virtualbox do |provider|
        provider.gui = false
        provider.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]

        if defined?(node["cpus"]) && (node["cpus"] != nil)
          provider.cpus = node["cpus"]
        else
          provider.cpus = default_cpus
        end


        if defined?(node["memory"]) && (node["memory"] != nil)
          provider.memory = node["memory"]
        else
          provider.memory = default_memory
        end


      end  # end machine provider
    end  # end config define
  end  # end nodes

  if File.exist?(ANSIBLE_SETUP_PATH)
    # load ansible configuration from inventory.yaml
    require ANSIBLE_SETUP_PATH
     config.vm.provision "ansible" do |ansible|
       ansible.verbose  = $ansible_verbosity
       ansible.playbook = $ansible_playbook
       ansible.groups   = $ansible_groups
       ansible.limit    = $ansible_limit
      #  ansible.galaxy_role_file = "#{ANSIBLE_ROOT}/requirements.yml"
      #  ansible.galaxy_roles_path = "#{ANSIBLE_ROOT}/roles"
       if defined?($ansible_tags) && ($ansible_tags != nil)
         ansible.tags   = $ansible_tags
       end
       if defined?($ansible_extra_vars) && ($ansible_extra_vars != nil)
         ansible.extra_vars = $ansible_extra_vars
       end
      #  ansible.raw_arguments = ['--sudo']
     end
   end

end
