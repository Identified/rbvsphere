# Since rbvmomi sucks... lazily load and memoize attributes
module VSphere
  class VM
    module Attributes
      def vm
        @vm
      end
      
      attr_reader :vm, :annotations, :name, :summary, :notes, :template, :uuid, :hostname, :ip_address, :os, :state
      alias_method :tags, :annotations
      
      
      def setup_attributes opts = {}

        @name       ||= opts["name"]                        || vm.name
        @summary    ||= opts["summary"]                     || vm.summary
        config = opts["config"] || vm.config
        @notes      ||= config.annotation
        @uuid       ||= config.instanceUuid
        @hostname   ||= summary.guest.hostName
        @ip_address ||= summary.guest.ipAddress     
        @template   ||= summary.config.template
        @os         ||= summary.guest.guestFullName 

        
        @state       ||= POWER_STATES[ summary.runtime.powerState ]
        @annotations ||= Annotations.new self, opts
        
      end
      
      def server?
        !template
      end
    
      def template?
        template
      end

      
      def reload_attributes
        @state = nil
        @summary = nil
        setup_attributes
      end
      
    end
  end
end
