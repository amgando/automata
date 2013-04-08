require 'active_record'

ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database  => %x[pwd].chomp + "/feedback.db"
)

class Question < ActiveRecord::Base
  has_many :answers
end

class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :student
  belongs_to :value
end

class Value < ActiveRecord::Base
  has_many :answers
end

class Cohort < ActiveRecord::Base
  has_many :students
end

class Student < ActiveRecord::Base
  belongs_to :cohort
  has_many :answers
end
  