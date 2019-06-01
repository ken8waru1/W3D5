class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      self.define_method(name) do
        self.instance_variable_get("@#{name}")
      end
  
      self.define_method("#{name}=") do |val|
        self.instance_variable_set("@#{name}", val)
      end
    end
  end
end
