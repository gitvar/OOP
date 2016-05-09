# student_exercise_7.rb

class Student

attr_accessor :name

  def initialize(name, grade)
    @name = name
    @grade = grade
  end

  def better_grade_than?(other_student)
    if grade > other_student.grade     # Calling other_student.grade
      true                             # from WITHIN this object (joe).
    else                               # So it has to be a call to a
      false                            # protected method. Not a private
    end                                # method as it will throw an error.
  end

  protected
    def grade
      @grade
    end
end

joe = Student.new('joe', 86)
bob = Student.new('bob', 53)

puts "Well done!" if joe.better_grade_than?(bob)    # => "Well done!"
