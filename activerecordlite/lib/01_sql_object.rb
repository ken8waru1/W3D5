require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

#table_name is instance variable

class SQLObject
  def self.columns
    @columns ||= DBConnection.instance.execute2(<<-SQL)
      SELECT 
        *
      FROM
        #{self.table_name}
      SQL

    @columns.first.map!(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |column|
      self.define_method(column) do
        @attributes[column]
      end

      self.define_method("#{column}=") do |val|
        @attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name = "#{self.name.downcase}s"
  end

  def self.all
    self.parse_all(DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      SQL
      )
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id: id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = :id
    SQL
    return nil if result.empty?

    self.new(result.first)
  end

  def initialize(params = {})
    @params = params
    
    @params.each do |attr_name, val|
      attr_sym = attr_name.to_sym
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_sym)
      self.send("#{attr_sym}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.attributes.values
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
