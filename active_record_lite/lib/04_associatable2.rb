require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do 
      middle_man = self.send(through_name)
      middle_man.send(source_name)
    end
    # ...
  end
end
