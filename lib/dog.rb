class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes = {})
    attributes = attributes.each_with_object({}) do |(key, value), memo|
      memo[key.to_sym] = value
    end

    @id = attributes[:id]
    @name = attributes[:name]
    @breed = attributes[:breed]
  end

  def self.create_table
    DB[:conn].execute(<<-SQL)
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, name, breed)
    self.id = DB[:conn].last_insert_row_id
    self
  end

  def self.create(name:, breed:)
    dog = new(name: name, breed: breed)
    dog.save
  end

  def self.new_from_db(row)
    id, name, breed = row
    new(id: id, name: name, breed: breed)
  end

  def self.all
    DB[:conn].execute("SELECT * FROM dogs").map do |row|
      new_from_db(row)
    end
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).first
    row ? new_from_db(row) : nil
  end

  def self.find(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).first
    row ? new_from_db(row) : nil
  end
end
