module VSphere
  module VMFinders
    # Servers
    [:name, :ip_address].each do |meth|
      send :define_method, "find_by_#{meth}"  do |opt|
        servers.select {|s| s.send(meth) == opt}.first
      end
    end
    
    # Templates
    [:name].each do |meth|
      send :define_method, "find_template_by_#{meth}"  do |opt|
        templates.select {|s| s.send(meth) == opt}.first
      end
    end
  end
end
