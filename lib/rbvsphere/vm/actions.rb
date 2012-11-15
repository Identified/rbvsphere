module VSphere
  class VM
    module Actions
      
      def start
        vm.PowerOnVM_Task.wait_for_completion
        reload
      end
      
      def stop force = false
        vm.ShutdownGuest
        sleep(2) and reload while state != :off
      end
      
      def halt
        vm.PowerOffVM_Task.wait_for_completion
        reload
      end
      
      def reboot force = false
        vm.RebootGuest.wait_for_completion
      end
      
      def reset
        vm.ResetVM_Task.wait_for_completion
        reload
      end
      
      def suspend
        vm.SuspendVM_Task.wait_for_completion
        reload
      end
      
      def destroy
        vm.Destroy_Task.wait_for_completion
        vm = nil
        VSphere.vms.delete self
      end
      
      
    end
  end
end