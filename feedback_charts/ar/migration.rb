require 'active_record'

ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database  => %x[pwd].chomp + "/feedback.db"
)

ActiveRecord::Schema.define do
    create_table :questions do |t|
        t.string :label
        t.timestamps
    end

    create_table :values do |t|
      t.string  :text
      t.integer :number
      t.timestamps
    end

    create_table :answers do |t|
      t.datetime :submitted_on
      t.integer :value_id
      t.integer :question_id
      t.integer :student_id
      t.timestamps
    end

    create_table :cohorts do |t|
      t.string :name
      t.timestamps
    end

    create_table :students do |t|
      t.string :name
      t.integer :cohort_id
      t.timestamps
    end
end
