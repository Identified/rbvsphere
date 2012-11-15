require 'rbvsphere/vm/attributes'
require 'rbvsphere/vm/actions'

module VSphere
  class VM

    
    include Attributes
    include Actions
    
    POWER_STATES = {
      'poweredOff' => :off,
      'poweredOn'  => :on,
      'suspended'  => :paused
    }
    
    def self.list vms
      vms = VSphere.vim.serviceContent.propertyCollector.collectMultiple(vms, "name", "summary", "config.annotation", "config.instanceUuid", "customValue", "availableField")
      vms.map{ |vm| 
        new *vm 
      } 
    end
    
    def initialize vm, opts = {}
      @vm = vm
      setup_attributes opts
    end
  
    
    def reload
      vm.Reload
      reload_attributes
    end
    
  end
end

require 'rbvsphere/vm/annotations'