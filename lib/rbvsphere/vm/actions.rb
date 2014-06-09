module VSphere
  class VM
    module Actions
      
      def start
        vm.PowerOnVM_Task.wait_for_completion
        while true
          reload
          break if vm.summary.guest.toolsStatus == "toolsOk"
        end
        reload
      end
      
      def stop force = false
        vm.ShutdownGuest
        sleep(2) and reload rescue nil while state != :off
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
      
      def full_restart
        stop
        start
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
      
      def snapshot(opts = {})
        opts = opts.merge({name: Time.now.utc.strftime('%Y%m%d%H%M'), quiesce: true, memory:false})
        vm.CreateSnapshot_Task(opts).wait_for_completion
      end

      def revert_snapshot
        vm.RevertToCurrentSnapshot_Task.wait_for_completion
        vm.start.wait_for_completion
      end
    end
  end
end