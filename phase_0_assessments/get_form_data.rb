require 'wuparty'

ACCOUNT     = "devbootcamp"
API_KEY     = "X1HQ-ZU20-12O7-0SD9"
ASSESSMENT	= "assessment-submission"

fields = {question_09: 'Field217',
		  question_10: 'Field218',
		  question_11: 'Field219',
		  time_to_complete: 'Field215',
		  well_prepared: 'Field6',
		  clear_instructions: 'Field7',
		  help_was_available: 'Field8',
		  prep_exceeded_expectations: 'Field9',
		  feedback: 'Field107'}


wufoo = WuParty.new(ACCOUNT, API_KEY)

form = wufoo.form(ASSESSMENT)

options = {:limit => 100}
e = form.entries(options)
p e.length
__END__
e.each {|r| p r}

__END__
# get new, unreviewed entries
# options = {:limit => 100, :filters => [['Field648','Is_equal_to','']] }
# e = form.entries (options)
# e.each {|e| p e['Field6']}

# get "too thin" entries
# options = {:sort => 'Field648 DESC'}#, :filters => [['Field648','Begins_with', '-1']] }
# e = []
# 5.times do |idx|
#   start = ((idx) *100) + 1
#   p start
#   options = {:pageSize => 100, :pageStart => start, :filters => [['Field648','Begins_with', '-1']] }
#   e += form1.entries (options)
# end


# e2 = form2a.entries :pageSize => 100#, :filters => [['Field231','Begins_with', 'Jamal']]
# e2.each {|en| puts en}

f = File.open('outcomes.txt', 'w+')

e = []
idx = 0
pgsize = 10
while true
  start = ((idx) *pgsize) + 1
  puts start
  options = {:pageSize => pgsize, :pageStart => start} #, :filters => [['Field648','Begins_with', '-1']] }
  e += form2a.entries (options)
  idx += 1
  f.write(e)
  break if idx > 5
end

p e