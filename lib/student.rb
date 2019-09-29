require_relative "../config/environment.rb"

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE IF NOT EXISTS students (
          id INTEGER PRIMARY KEY,
          name TEXT,
          grade INTEGER
        );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students;")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade) 
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db(student_rows)
    id = student_rows[0]
    name = student_rows[1]
    grade = student_rows[2]
    student = self.new(name, grade, id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE students.name = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map{|student_rows|self.new_from_db(student_rows)}.first
  end

  def update
    sql = <<-SQL 
      UPDATE students
      SET name = ?, grade = ? 
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end #end of Student class
