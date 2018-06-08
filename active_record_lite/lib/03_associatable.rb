require 'byebug'
require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    self.class_name.constantize
  end

  def table_name
    # ...
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
    self.class_name = options[:class_name] ? options[:class_name] : name.to_s.singularize.camelcase
    self.foreign_key = options[:foreign_key] ? options[:foreign_key] : "#{name}_id".downcase.to_sym
    self.primary_key = options[:primary_key] ? options[:primary_key] : :id
    
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ...
    self.class_name = options[:class_name] ? options[:class_name] : name.to_s.singularize.camelcase
    self.foreign_key = options[:foreign_key] ? options[:foreign_key] : "#{self_class_name}_id".downcase.to_sym
    self.primary_key = options[:primary_key] ? options[:primary_key] : :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})#cat option = {:human, foreign_key: :owner_id}
    # ...
    the_thing = BelongsToOptions.new(name, options)
    method_name = the_thing.class_name.to_s.downcase
    define_method(method_name) do
      foreign_key = the_thing.send(:foreign_key)
      thing_class = the_thing.send(:model_class)
      search_key = self.send(foreign_key)
      thing_class.where(id: search_key).first
    end
    lower_case_class = the_thing.class_name.to_s.downcase.to_sym
    self.assoc_options[lower_case_class] = the_thing
    
  end

  def has_many(name, options = {})
    # ...
    the_thing = HasManyOptions.new(name, self.to_s, options)
    method_name = "#{the_thing.model_class.to_s}s".downcase
    define_method(method_name) do
      foreign_key = the_thing.send(:foreign_key)
      thing_class = the_thing.send(:model_class)
      search_key = self.id
      thing_class.where(foreign_key => self.id)
    end
  end

  def assoc_options
    @assoc_options ||= {}
    
  end
end

class SQLObject
  extend Associatable
  # Mixin Associatable here...
end
