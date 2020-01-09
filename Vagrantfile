# -*- mode: ruby -*-
# vi: ft=ruby :

require 'rbconfig'
require 'yaml'

# Set your default base box here
DEFAULT_BASE_BOX = 'bertvv/centos72'

#
# No changes needed below this point
#

VAGRANTFILE_API_VERSION = '2'
PROJECT_NAME = '/' + File.basename(Dir.getwd)

hosts = YAML.load_file('vagrant-hosts.yml')

# {{{ Helper functions

def is_windows
  RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
end

# Set options for the network interface configuration. All values are
# optional, and can include:
# - ip (default = DHCP)
# - netmask (default value = 255.255.255.0
# - mac
# - auto_config (if false, Vagrant will not configure this network interface
# - intnet (if true, an internal network adapter will be created instead of a
#   host-only adapter)
def network_options(host)
  options = {}

  if host.has_key?('ip')
    options[:ip] = host['ip']
    options[:netmask] = host['netmask'] ||= '255.255.255.0'
  else
    options[:type] = 'dhcp'
  end

  if host.has_key?('mac')
    options[:mac] = host['mac'].gsub(/[-:]/, '')
  end
  if host.has_key?('auto_config')
    options[:auto_config] = host['auto_config']
  end
  if host.has_key?('intnet') && host['intnet']
    options[:virtualbox__intnet] = true
  end

  options
end

def custom_synced_folders(vm, host)
  if host.has_key?('synced_folders')
    folders = host['synced_folders']

    folders.each do |folder|
      vm.synced_folder folder['src'], folder['dest'], folder['options']
    end
  end
end

# Adds forwarded ports to your Vagrant machine
#
# example:
#  forwarded_ports:
#    - guest: 88
#      host: 8080
def forwarded_ports(vm, host)
  if host.has_key?('forwarded_ports')
    ports = host['forwarded_ports']

    ports.each do |port|
      vm.network "forwarded_port", guest: port['guest'], host: port['host']
    end
  end
end


# }}}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false
  hosts.each do |host|
    config.vm.define host['name'] do |node|
      node.vm.box = host['box'] ||= DEFAULT_BASE_BOX
      node.vm.box_version = host['version']
      if(host.key? 'box_url')
        node.vm.box_url = host['box_url']
      end

      node.vm.hostname = host['name']
      node.vm.network :private_network, network_options(host)
      custom_synced_folders(node.vm, host)
      forwarded_ports(node.vm, host)

      node.vm.provider :virtualbox do |vb|
        vb.gui    = host['gui']
        vb.cpus   = host['cpus'] if host.key? 'cpus'
        vb.memory = host['memory'] if host.key? 'memory'
        
        # WARNING: if the name of the current directory is the same as the
        # host name, this will fail.
        vb.customize ['modifyvm', :id, '--groups', PROJECT_NAME]
        if host['name'] == "WIN-CLT"
          vb.customize [
            'modifyvm', :id,
            '--boot1', 'net',
            '--boot2', 'disk',
            '--boot3', 'none',
            '--boot4', 'none'
          ]
        end
      end

      # use the plaintext WinRM transport and force it to use basic authentication.
      # This is needed because the default negotiate transport stops working
      #    after the domain controller is installed.
      #    see https://groups.google.com/forum/#!topic/vagrant-up/sZantuCM0q4
      config.winrm.transport       = :plaintext
      config.winrm.basic_auth_only = true
      config.winrm.timeout         = 3600 # 60 minutes
      config.vm.boot_timeout       = 3600 # 60 minutes

      if host['name'] == "WIN-DC1"
        provision_files="provisioning/WIN-DC1/"

        node.vm.provision 'shell',
          privileged: true,
          path: provision_files + "/1_adapter.ps1",
          args: []
        node.vm.provision 'shell',
          privileged: true,
          path: provision_files + "/2_dc_install.ps1",
          args: []
        node.vm.provision 'shell', reboot: true
        node.vm.provision 'shell',
          privileged: true,
          path: provision_files + "/3_dc_conf.ps1",
          args: []
        node.vm.provision 'shell',
          privileged: true,
          path: provision_files + "/4_dns_fix.ps1",
          args: []
        node.vm.provision 'shell',
          privileged: true,
          path: provision_files + "/5_dns_config.ps1",
          args: []
      elsif host['name'] == "WIN-DC2"
        provision_files="provisioning/WIN-DC2/"

        node.vm.provision 'shell',
          privileged: true,
          path: provision_files + "/1_adapter.ps1",
          args: []
        node.vm.provision 'shell',
          privileged: true,
          path: provision_files + "/2_dc_install.ps1",
          args: []
        node.vm.provision 'shell', reboot: true
        node.vm.provision 'shell',
          privileged: true,
          path: provision_files + "/3_dns_fix.ps1",
          args: []
      elsif host['name'] == "WIN-CLT1"
        node.vm.provision 'shell', 
          privileged: true, 
          path: "provisioning/1_client.ps1", 
          args: []
        node.vm.provision 'shell', reboot: true
      elsif host['name'] == "WIN-EXC-SHP"
        provision_files="provisioning/WIN-EXC-SHP/"

        node.vm.provision 'shell',
          privileged: true,
          path: provision_files + "/1_adapter.ps1",
          args: []
        node.vm.provision 'shell', 
          privileged: true, 
          path: provision_files + "/2_join_domain.ps1",
          args: []
        node.vm.provision 'shell', 
          privileged: true, 
          path: provision_files + "/3_exc_prereq.ps1",
          args: []
        node.vm.provision 'shell', reboot: true
      elsif host['name'] == "WIN-SQL-SCCM"
        provision_files="provisioning/WIN-SQL-SCCM/"

        node.vm.provision 'shell',
          privileged: true,
          path: provision_files + "/1_adapter.ps1",
          args: []
        node.vm.provision 'shell', 
          privileged: true, 
          path: provision_files + "/2_join_domain.ps1",
          args: []
        node.vm.provision 'shell', reboot: true
        node.vm.provision 'shell',
          privileged: true,
          path: provision_files + "/3_sql_install.ps1",
          args: []
        node.vm.provision 'shell', reboot: true
      end
    end
  end
end

