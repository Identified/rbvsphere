module VSphere
  class VM
    class Annotations
      
      attr_reader :vm, :annotations
        
      def initialize vm
        @vm = vm
        
        vals = vm.vm.customValue.inject({}) { |vs, cf| 
          values =  cf.value.split ?,
          values.map(&:strip!)
          if values.length > 1
            vs[cf.key] = values
          else 
            vs[cf.key] = values.first
          end
          vs 
        }
        
        
        @annotations = vm.vm.availableField.inject({}) { |annos, cfd| 
          annos[cfd.name.downcase.to_sym] = vals[cfd.key]
          annos 
        }
        
        annotations.each do |key, value|
          self.class.class_exec do
            define_method(key) { @annotations[key] }
          end
        end
      end
      
      def [] key
        annotations[key]
      end

      def add key, val
        vm.vm.setCustomValue key: key, value:val
        annotations[key] = val
      end

      def to_s
        annotations.to_s
      end
      
      def =~ filter
        if annotations[filter[0]].is_a? Array 
          f = [ filter[1] ].flatten
          annotations[filter[0]] | f == annotations[filter[0]]
        else
          annotations[filter[0]] == filter[1]
        end
      end
    end
  end
end
