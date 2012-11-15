module VSphere
  module VMFilters
    def servers
      vms.select{ |vm| vm.server? }
    end
    
    def threaded_servers
      vms.select{ |vm| !vm.template? }
    end
  
    def running_servers
      servers.select{ |vm| vm.state == :on }
    end
  
    def templates
      vms.select{ |vm| vm.template? }
    end
  
    def filter_servers filters = {}
      filters.inject(running_servers) { |servers, filter|
        servers.select{ |s| s.annotations =~ filter }
      }
    end 
  end
end