require_relative 'model.rb'
require 'csv'

# CSV.foreach("weekly-retro-lookup.csv") do |row|
#   unless row[0].nil?
#     Value.create(text: row[0], number: row[1])
#   end
# end

# CSV.foreach("weekly-retro-raw.csv", :headers => true) do |row|
#   row.headers[1..-4].each do |h|
#     p h
#     Question.create(:label => h)
#   end
#   break
# end


__END__

CSV.foreach("weekly-retro-raw.csv", :headers => true, :return_headers => false, :header_converters => :symbol) do |row|
  p row.headers
  exit
end


__END__
q = Question.create(:label => 'whatcha doin tomorra?')
c = Cohort.create(:name => 'sea lions')
s = Student.create(:name => 'john', :cohort => c)
v = Value.create(:text => 'no', :number => 1)

q.answers.create(:student => s, :value => v)

p Question.all.last.answers

a = Answer.all.last
a.value = v

p a
p Value.all

