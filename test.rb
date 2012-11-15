$: << './lib'

load 'rbvsphere.rb'
require 'pry'

def reload
  load 'rbvsphere.rb'
end


VSphere.connect

binding.pry