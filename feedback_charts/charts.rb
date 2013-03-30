#BUGBUG: Hide password
#Assumptions: 
#  Spreadsheet has raw tab and lookup tab
#  lookup data is always consistent across all questions per survey
#TODO: Stock tickers / list of gainers/winners

require "google_drive"
require 'active_support/core_ext'

begin
  session = GoogleDrive.login("sherif@devbootcamp.com", 'sherif11')
rescue GoogleDrive::AuthenticationError => error
  p error
  exit
end

WEEKLY_RETRO = "0Ag1udyiPyRNrdFBkcVFyNFlDUjlkZE9nbWY3a2h4MUE"


ws = session.spreadsheet_by_key(WEEKLY_RETRO).worksheets[0]

lookup_ws = nil
@raw_ws = nil
session.spreadsheet_by_key(WEEKLY_RETRO).worksheets.each do |ws|
  lookup_ws = ws if ws.title == "Lookup"
  @raw_ws = ws if ws.title == "Raw"
end


LOOKUP = Hash[lookup_ws.rows]
# p lookup
# p @raw_ws.rows.count
# p @raw_ws.rows[0].inspect


class Question
  attr_accessor :text
  def initialize(t)
    @text = t
  end

  def to_s
    @text
  end
end

class Response
  attr_accessor :date, :time, :student, :cohort, :question, :text, :ordinal

  def initialize(args)
    @date, @time  = args[:timestamp].split  # 2/1/2013 10:16:21
    @student      = args[:student]
    @cohort       = args[:cohort] 
    @question     = args[:question]
    @text         = args[:text]
    @ordinal      = args[:ordinal]
  end

  # def to_s
  #   "[%s] responded with [%s (%s)] to [%s] on [%s] at [%s]" % [@student, @text, @ordinal, @question, @date, @time]
  # end
end

__END__

header = @raw_ws.rows[0]

questions = header[1..-4].map{|q| Question.new(q)}

responses = []

@raw_ws.rows[1..-1].each do |row|

  timestamp = row[0]

  cohort = row[-1]
  student = row[-2]
  comments = row[-3]

  # puts "%s | %s | %s | %s" % [timestamp, student, cohort, comments]

  # at this point row and question_text are aligned.  this is fucked up.

  row[1..-4].each_with_index do |cell, idx|
    resp = Response.new({ timestamp: timestamp, 
                          student:   student, 
                          cohort:    cohort,
                          question:  questions[idx], 
                          text:      cell,
                          ordinal:   LOOKUP[cell].to_f})
    responses << resp
  end

end

# p responses.length
# p responses.first
# p responses.last


# NOTE: At the end of this HORRIFYING code, we'll end up with this:
#
# { 'How are you?' =>
#   { 'Stinky Bastards' =>
#     { '3/15/2013' => 2.02,
#       '3/22/2013' => 3.89,
#       '3/29/2013' => 2.41 },
#     'Minky Bastards' =>
#     { '3/15/2013' => 2.02,
#       '3/22/2013' => 3.89,
#       '3/29/2013' => 2.41 }
#   }
# }
#
# Good luck debugging.

responses_by_question = responses.group_by do |response|
  response.question
end

chart_data = {}

responses_by_question.each do |question, response_array|
  chart_data[question] = response_array.group_by do |response|
    response.cohort
  end

  responses_by_cohort = {}
  chart_data[question].each do |cohort, response_array2|
    responses_by_cohort[cohort] = response_array2.group_by do |r18395|
      r18395.date
    end
  end

  response_averages_by_cohort_and_date = {}  
  responses_by_cohort.each do |cohort, date_hash|
    collapsed_by_date = {}
    date_hash.each do |date, resp_array| 
      collapsed_by_date[date] = (resp_array.map{|r| r.ordinal}.inject(&:+) / resp_array.length).round(2)
    end
    response_averages_by_cohort_and_date[cohort] = collapsed_by_date
  end

  chart_data[question] = response_averages_by_cohort_and_date
end

File.open('data.dump.txt', 'w').write(chart_data.to_yaml)


# data = {}

# questions.each do |q|
#   resp_for_q = responses.select{|r| r.question == q }
#   # p resp_for_q
#   data[q] = nil
#   cohorts_as_keys = resp_for_q.group_by{|rfq| rfq.cohort }
#   dates_as_keys = cohorts_as_keys.group_by{|cak| cak.date}
#   p dates_as_keys  

#   break
# end


# now i have a collection of responses with all the right data.
# munge that shit.
#
# q = question
# c = cohort
# d = date
# s = score
# ----------
# {'q1' =>
#   [ {'c1' =>
#       [{'d1' => 's1'},
#        {'d2' => 's2'},
#        {'d3' => 's3'}]
#   },{'c2' =>
#       [{'d1' => 's1'},
#        {'d2' => 's2'},
#        {'d3' => 's3'}]
#   },{'c3' =>
#       [{'d1' => 's1'},
#        {'d2' => 's2'},
#        {'d3' => 's3'}]
#   }]
# }










__END__
def scrub_date(timestamp)
  Date.strptime(timestamp, "%m/%d/%Y").to_s
end

# Builds list of questions by going through first row of answers. 
# If the answer exists in the lookup, then this is a question we're concerned with
@question_list = []

@raw_ws.rows[1].each_with_index do |cell,index|
  @question_list.push Hash[@raw_ws.rows[0][index], index] if lookup[cell] && !lookup[cell].empty?
end

@week_list = Hash.new(0)
@raw_ws.rows.each do |cell|
  next if cell[0] == "Timestamp"
  timestamp = cell[0]
  week_string = scrub_date(timestamp)
  @week_list[week_string] += 1
end

#TODO: trim dates that are off and cluster them

# Build list of cohorts

@cohort_list = Hash.new(0)
@cohort_index = 0
# Find index of cohort column
@raw_ws.rows[0].each_with_index do |column_title, index|
  if column_title == "Cohort"
    @cohort_index = index
    break
  end
end

@raw_ws.rows.each do |cell|
  cohort_name = cell[@cohort_index]
  next if cohort_name == "Cohort"
  @cohort_list[cohort_name] += 1
end

# Returns average value for all cells for this question, cohort and week
def week_data(question_index, cohort_name, week)
  sum = 0
  count = 0
  @raw_ws.rows.each do |cell|
    next if cell[@cohort_index] != cohort_name
    next if scrub_date(cell[0]) != week
    sum += cell[question_index]
    count += 1
  end
  sum * 1.0 / count
end


# Builds data for the question and cohort name provided
# Data is in the form of an array 
#   each key is a date
#   each value is the average for that cohort for that date
def cohort_data(question_index, cohort_name)
  value = []
  @week_list.each do |week|
    puts "week #{week}"
    puts "week data #{week_data(question_index, cohort_name, week)}"
    value.push Hash.new [week[0],week_data(question_index, cohort_name, week[0])]
  end
  value
end

# Builds data for the question at the row provided
# Data is in the form of an array of hashes
#  each key is a cohort
#  each value is an array of hashes
#   each key is a date
#   each value is the average

def question_data(question_index)
  value = []
  @cohort_list.each do |cohort_name|
    value.push Hash.new [cohort_name, cohort_data(question_index, cohort_name)]
  end
  value
end

# Build master hash
# Hash each key is a question
# each value is an array of hashes
#  each key is a cohort
#  each value is an array of hashes
#   each key is a date
#   each value is the average

questions = {}

@question_list.each do |q|
  question_title = q.keys[0]
  question_index = q.values[0]
  questions[question_title] = question_data(question_index)
end

p questions.inspect



