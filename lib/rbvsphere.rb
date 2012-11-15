require 'yaml'
require 'rbvmomi'
require 'rbvsphere/vm'
require 'rbvsphere/vm_filters'
require 'rbvsphere/vm_finders'
require 'rbvsphere/vm_actions'
require 'benchmark'

module VSphere
  VSPHERE_CONFIG = File.expand_path("~/.vsphererc")
  
  extend VMFilters
  extend VMFinders
  extend VMActions
    
  def self.connect opts = {}
    if File.exists? VSPHERE_CONFIG
      opts = YAML.load_file(VSPHERE_CONFIG).merge(opts)
    end
    
    @config = opts
    
    @vim          = RbVmomi::VIM.connect opts
    @dc           = @vim.serviceInstance.find_datacenter(opts[:datacenter]) or raise "datacenter not found"
    @cluster      = @dc.hostFolder.find(opts[:cluster]) or raise "cluster not found"
    @vm_datastore = @dc.datastoreFolder.find('vmfs-vm1')
    @template_datastore = @dc.datastoreFolder.find('vmfs-templates')
    
    true
  rescue => e
    puts e.inspect
    false
  end
  
  def self.vms
    @vms ||= begin
      VM.list @vim.serviceContent.viewManager.CreateContainerView({
        container: @vim.rootFolder,
        type:  ['VirtualMachine'],
        recursive: true
      }).view
    end
  end
  
  def self.reload
    @vms = nil
    true
  end
  
  # Errors
  class Error < StandardError; end

  # Accessors
  def self.dc;      @dc;      end
  def self.vim;     @vim;     end
  def self.config;  @config;  end
  def self.cluster; @cluster; end
  def self.vm_datastore; @vm_datastore; end
  def self.template_datastore; @template_datastore; end
    
end

