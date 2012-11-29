module VSphere::VM::Configure
  
  # opts: {
  #   nics: {
  #     1: { vlan: new_portgroup_1 },
  #     2: { vlan: new_portgroup_2 },
  #     ...
  #   },
  #   cpus:   new_cpu_count,
  #   memory: new_memory_size
  # }
  def update_config opts
    change_spec = RbVmomi::VIM.VirtualMachineConfigSpec deviceChange: []
    
    update_nics   change_spec, opts if opts[:nics]
    update_cpus   change_spec, opts if opts[:cpus]
    update_memory change_spec, opts if opts[:memory]
    
    vm.ReconfigVM_Task spec: change_spec
  end
  
  def update_config! opts
    update_config(opts).wait_for_completion
  end
  
  
  private # -------------------------------------------------------------------
  
  def update_nics config_spec, opts
    nics = vm.config.hardware.device.select{ |d| d.is_a? RbVmomi::VIM.VirtualEthernetCard.class }
    opts[:nics].each do |nic_id, conf|
      dev = nics.select{ |d| d.deviceInfo.label.split.last.to_i == nic_id.to_i}.first
      dev || raise( "NIC not found with id #{nic_id}" )
      
      network = VSphere.find_network(conf[:vlan])
      case network
      when RbVmomi::VIM::DistributedVirtualPortgroup
        port = RbVmomi::VIM.DistributedVirtualSwitchPortConnection({
          switchUuid:   network.config.distributedVirtualSwitch.uuid,
          portgroupKey: network.key 
        })
        dev.backing = RbVmomi::VIM.VirtualEthernetCardDistributedVirtualPortBackingInfo port: port
        
      when RbVmomi::VIM::Network
        dev.backing = RbVmomi::VIM.VirtualEthernetCardNetworkBackingInfo(deviceName: conf[:vlan])
      end
      
      vm_dev_spec = RbVmomi::VIM.VirtualDeviceConfigSpec(device: dev, operation: 'edit')
      
      config_spec.deviceChange << vm_dev_spec
    end
  end
  
  def update_cpus config_spec, opts
    #TODO: allow dynamicly changing of cpus
    raise "update_cpus - Unimplemented"
  end
  
  def update_memory config_spec, opts
    #TODO: allow dynamicly changing of memory
    raise "update_memory - Unimplemented"
  end
end

