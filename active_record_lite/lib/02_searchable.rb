require 'byebug'
require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    col_names_map = params.keys.map {|key| key.to_s}
    if col_names_map.length == 1 
      col_names = "#{col_names_map.first} = ?"
    else 
      col_names = "#{col_names_map.join(" = ? AND ")} = ?"
    end
    table = self.table_name 
    value = params.values
    result = DBConnection.execute(<<-SQL, *value)
      SELECT
      *
      FROM 
      #{table}
      WHERE
      #{col_names}
    SQL
    self.parse_all(result)
  end
end

class SQLObject
  extend Searchable
  # Mixin Searchable here...
end
