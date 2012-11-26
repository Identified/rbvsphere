require 'ipaddr'

module VSphere
  module VMActions
    
    def launch_from_template opts = {}
      vm = clone_from_template opts
      vm.start
      vm
    end
    
    def clone_from_template opts = {}
      vm = clone_from_template_task(opts).wait_for_completion
      VM.new(vm).tap { |new_vm| @vms << new_vm }
    end
      
    def bulk_clone_from_template num, prefix, start_ip, opts = {}
      tasks = []
      vms   = []
      
      # Start cloning vms
      1.upto num do |i|
        name = "#{prefix}-%0#{[num.to_s.length, 2].max}d" % i
        ip = ip_add(start_ip, i-1)
        puts "Launching: #{name} - #{ip}"
        
        tasks << clone_from_template_task( opts.merge(ip: ip, name: name) )
      end
      
      # Wait for vms to finish cloning
      tasks.map { |t|
        vm = t.wait_for_completion
        VM.new(vm).tap { |new_vm| 
          @vms << new_vm 
          vms << new_vm
        }
      }
      
      vms
    end
    

    def rename_vm vm, new_name
      vm.vm.Rename_Task(newName: new_name).wait_for_completion
    end

    def swap_vms vm1, vm2
      cs1 = build_customization_spec name: vm2.name, ip: vm2.ip_address
      cs2 = build_customization_spec name: vm1.name, ip: vm1.ip_address
    
      rename_vm vm1, "#{vm1.name}-tmp"
      rename_vm vm2, vm1.name
      rename_vm vm1, vm2.name

      vm1.stop 
      vm2.stop
  
      vm1.vm.CustomizeVM_Task(spec: cs1).wait_for_completion
      vm2.vm.CustomizeVM_Task(spec: cs2).wait_for_completion
    
      vm1.start 
      vm2.start
  
      vm1.full_restart
      vm2.full_restart
  
    end
    
    private
    
    

    def ip_add ip_string, n
      ip = IPAddr.new ip_string
      IPAddr.new(ip.to_i + n, ip.family).to_s
    end
    
    def clone_from_template_task opts = {}      
      vm = opts[:template].is_a?(String) ? find_template_by_name(opts[:template]).vm : opts[:template].vm

      folder          = find_folder_for_vm(opts) || vm.parent
      customize_spec  = build_customization_spec(opts)
      relocation_spec = RbVmomi::VIM.VirtualMachineRelocateSpec({
        pool: find_resource_pool(opts),
        datastore: vm_datastore
      })

      clone_spec = RbVmomi::VIM.VirtualMachineCloneSpec({
        location:      relocation_spec, 
        customization: customize_spec,
        powerOn:       false,
        template:      false
      })
            
      vm.CloneVM_Task({
        folder: folder, 
        spec:   clone_spec,
        name:   opts[:name]
      })
    end
    
    
    def find_folder_for_vm opts
      path = opts[:path] || "#{opts[:stage].capitalize}/#{opts[:subnet].capitalize}"
      folder = dc.vmFolder.traverse(path)
    end
    
    
    def build_customization_spec opts
      hostname     = opts[:name]
      ip           = opts[:ip]           || "172.31.30.254"
      gateway      = opts[:gateway]      || "172.31.30.1"
      subnet_mask  = opts[:subnet_mask]  || "255.255.255.0"
      domain       = opts[:domain]       || "identified.com"
      dns_servers  = opts[:dns_servers]  || ["172.31.10.37", ""]
      dns_suffixes = opts[:dns_suffixes] || ["identified.com"]
      
      
      identity = RbVmomi::VIM.CustomizationLinuxPrep({
        hostName:   RbVmomi::VIM.CustomizationFixedName(name: hostname),
        domain:     domain,
        hwClockUTC: true
      }) 
      
      global_ip_settings = RbVmomi::VIM.CustomizationGlobalIPSettings({
        dnsServerList: dns_servers,
        dnsSuffixList: dns_suffixes
      })
      
      ip_settings = RbVmomi::VIM.CustomizationIPSettings({
        ip:         RbVmomi::VIM.CustomizationFixedIp(ipAddress: ip),
        gateway:    [gateway],
        subnetMask: subnet_mask
      })
      
      adapter_mapping = RbVmomi::VIM.CustomizationAdapterMapping adapter: ip_settings
      
      
      RbVmomi::VIM.CustomizationSpec({
        identity:         identity,
        nicSettingMap:    [adapter_mapping],
        globalIPSettings: global_ip_settings,
        options:          RbVmomi::VIM.CustomizationLinuxOptions
      })

    end
    
    def find_resource_pool opts
      cluster.resourcePool.find(opts[:resource_pool] || opts[:stage] || 'production')
    end
  end
end