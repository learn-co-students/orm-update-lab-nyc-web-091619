require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def update
  end

  def save
    if self.id
      update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn]. execute(sql, name, grade)
      @id = DB[:conn]. execute("SELECT last_insert_rowid() FROM students")[0][0]
    end

  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL

    DB[:conn]. execute(sql, name, grade, id)

  end


  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    student = self.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name_to_find)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
    SQL

    DB[:conn]. execute(sql, name_to_find).map do |row|
      new_from_db(row)
    end.first

  end


  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL

    DB[:conn]. execute(sql)

  end

  def self.drop_table
    DB[:conn]. execute("DROP TABLE students")
  end


end
