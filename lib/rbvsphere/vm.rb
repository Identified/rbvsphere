require_relative 'vm/attributes'
require_relative 'vm/actions'
require_relative 'vm/configure'


module VSphere
  class VM

    
    include Attributes
    include Actions
    include Configure
    
    POWER_STATES = {
      'poweredOff' => :off,
      'poweredOn'  => :on,
      'suspended'  => :paused
    }
    
    def self.list vms
      vms = VSphere.vim.serviceContent.propertyCollector.collectMultiple(vms, "name", "summary", "config", "customValue", "availableField")

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

require_relative 'vm/annotations'
