# -*- mode: ruby -*-
# vi: set ft=ruby :


# for debugging: $ ruby ansible.rb
unless defined?(PROJECT_ROOT) && defined?(ANSIBLE_ROOT) && defined?(INVENTORY_PATH)
  PROJECT_ROOT=`git rev-parse --show-toplevel`.strip
  ANSIBLE_ROOT="#{PROJECT_ROOT}/ansible"

  require 'fileutils'
  require 'yaml'

  INVENTORY_PATH = File.join(File.dirname(__FILE__), "inventory.yaml")
end


inventory_yaml = open(INVENTORY_PATH).read
nodes = YAML.load(inventory_yaml)['nodes']
ansible_settings = YAML.load(inventory_yaml)['ansible'] || {}


# create inventory groups
if ansible_settings['inventory']
  # allow explicit inventory definition
  $ansible_groups = ansible_settings['inventory']
else
  groups = {}
  nodes.each do |node|
    # add hosts to group
    if defined?(node['tags']['groups']) && (node['tags']['groups'] != nil)
      node['tags']['groups'].each do |group|
        _tmp = groups[group] || []
        _tmp << node['tags']['name']
        groups[group] = _tmp
      end
    end
    # add hosts to type
    if defined?(node['tags']['type']) && (node['tags']['type'] != nil)
      _tmp = groups[node['tags']['type']] || []
      _tmp << node['tags']['name']
      groups[node['tags']['type']] = _tmp
    end
    # add groups and types to environment group
    groups['environment_vagrant:children'] = groups.keys
  end

  if groups['environment_vagrant:children'] == []
    # handle nil case
    groups['environment_vagrant:children'] = ['all']
  end
  # groups['environment_vagrant:children'] == [] ? groups['environment_vagrant:children'] = ['all'] : nil
  $ansible_groups = groups
end

# override defaults
$ansible_limit     = ansible_settings['limit'] || 'all'
$ansible_playbook  = "#{ANSIBLE_ROOT}/" << (ansible_settings['playbook'] || 'site.yml')
$ansible_verbosity = ansible_settings['verbosity'] || 'vv'
if ansible_settings['tags']
  $ansible_tags    = ansible_settings['tags'].join(',') || ''
end
if ansible_settings['extra_vars']
  # $ansible_extra_vars = ansible_settings['extra_vars'].join(',') || ''
  $ansible_extra_vars = ansible_settings['extra_vars'] || {}
end
# for debugging: $ ruby ansible.rb
# puts ansible_limit
# puts ansible_playbook
# puts $ansible_groups
# puts ansible_verbosity
# puts $ansible_tags
# puts $ansible_extra_vars
