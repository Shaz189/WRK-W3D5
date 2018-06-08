require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    if @var 
      return @var 
    else 
      # debugger
      table_name = self.table_name
      # debugger
      table_col = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
      SQL
      @var = table_col.first.map(&:to_sym)
    end
  end

  def self.finalize!
    
    column_names = self.columns
    column_names.each do |column|
      define_method(column) do 
        self.attributes[column]      
      end
      
      define_method("#{column}=") do |value|
        # debugger
        self.attributes[column] = value
      end
    end
  
  end

  def self.table_name=(table_name)
    # ...
    instance_variable_set("@table_name", table_name)
  end

  def self.table_name
    # ...
    instance_variable_set("@table_name", "#{self.to_s.downcase}s")
  end

  def self.all
    # ...
    table = self.table_name
    results = DBConnection.execute("SELECT * FROM #{table}")
    self.parse_all(results)
  end

  def self.parse_all(results)
    # ...
    # debugger
    results.map do |hash|
      # debugger
      self.new(hash)
    end 
  end

  def self.find(id)
    # ...
    self.all.select { |object| object.id == id }.first
  end

  def initialize(params = {})
    # ...
    params.each do |key, val|
      raise "unknown attribute '#{key}'" unless self.class.columns.include?(key.to_sym)
      self.send("#{key}=", val)
    end
  end

  def attributes
    @attributes ||= {}
    # ...
    
  end

  def attribute_values
    # ...
    self.attributes.values
  end

  def insert
    # ...
    column_edit = self.class.columns.dup
    column_edit.shift
    column = "(#{column_edit.join(", ")})"
    n = self.class.columns.count
    arr = ["?"] * (n - 1)
    join_string = "(#{arr.join(", ")})"
    table_name = self.class.table_name
    value = attribute_values
# debugger
    
    DBConnection.execute(<<-SQL, *value)
      INSERT INTO 
      #{table_name} #{column}
      VALUES
      #{join_string}
    SQL
    
    self.id = DBConnection.last_insert_row_id
    
  end

  def update
    column_edit = self.class.columns.dup
    column_edit.shift
    column = "#{column_edit.join(" = ?, ")} = ?"
    value = attribute_values.dup
    value.shift
    table_name = self.class.table_name
    n_id = self.id
    # debugger
    DBConnection.execute(<<-SQL, *value)
      UPDATE
      #{table_name} 
      SET
      #{column}
      WHERE
        id = #{n_id}
    SQL
    # ...
  end

  def save
    if self.id
      self.update 
    else 
      self.insert 
    end 
    # ...
  end
end
