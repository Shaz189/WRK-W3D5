require 'byebug'
class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    # def self.instance_variables_get(*names) 
    #   define_method(*names) {return names}
    # end 
    # debugger
    
    # def self.instance_variables_set(*names, value)
      names.each do |name|
        define_method(name) {instance_variable_get("@#{name}")}
        
        define_method("#{name}=") do |value|
          instance_variable_set("@#{name}", value)
        end
      end
    # end
  end
end
