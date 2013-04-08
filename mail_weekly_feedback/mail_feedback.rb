require 'mail'
require_relative '../lib/feedback'

######################################################################
#
#  Driver Code
#
######################################################################

MANUAL_DAY = nil
WEEKLY_RETRO = "0Ag1udyiPyRNrdFBkcVFyNFlDUjlkZE9nbWY3a2h4MUE"
# other spreadsheets here using their key from the URL
#   for example: URL?key=0Ag1udyiPyRNrdFBkcVFyNFlDUjlkZE9nbWY3a2h4MUE

def date
  return MANUAL_DAY unless MANUAL_DAY.nil?
  time = Time.new
  raise ArgumentError, "wrong day, dude." unless time.day == 5 #fridays
  "%s/%s" % [time.month, time.day]
end

# first run.  yay!
# reports = [{date: "3/8",  cohort: "Sea Lions",    teachers: %w[jeffrey shadi]}, 
#            {date: "3/15", cohort: "Sea Lions",    teachers: %w[jesse shadi]},
#            {date: "3/8",  cohort: "Banana Slugs", teachers: %w[brick anne]}, 
#            {date: "3/15", cohort: "Banana Slugs", teachers: %w[jeffrey anne]},
#            {date: "3/15", cohort: "Golden Bears", teachers: %w[brick zee]}]

# this is real data
reports = [
           {date: date, cohort: "Sea Lions",    size: 7, teachers: %w[myles]},
           {date: date, cohort: "Banana Slugs", size: 14, teachers: %w[keith shadi]},
           {date: date, cohort: "Golden Bears", size: 19, teachers: %w[jeffrey jared]},
           {date: date, cohort: "Fiery Skippers", size: 21, teachers: %w[zee mike]},
          ]

# this is fake data
# reports = [{date: date,   cohort: "Golden Bears",  size: 19, teachers: %w[sherif]}]


mail_domain = '@devbootcamp.com'
mail_footer = ""
mail_footer += "\n\n(please note that the data in these reports is only as good as the data we have.  i try to make sure to fix obvious errors in the raw data before sending these.  apologies in advance for mistakes.)"

feedback = Feedback.load_feedback_from_document(WEEKLY_RETRO)

Logger.log("generating reports as markdown...\n", '') do
  reports.each do |r|
    # teachers = r.select{|k,v| k =~ /teachers/}.values
    filename = r.select{|k,v| k !~ /teachers|size/}.values.reverse.join("_").gsub(/[\s\/]/,'_').downcase
    content = FeedbackViewer.render(feedback.all(r), r)
    File.open("in/#{filename}.md", 'w') { |file| file.write(content) }
  end

end

Logger.log("generating PDFs from #{reports.count} markdown file(s).\n\tthis can take a while depending on how many reports are going out.") do
  %x[gimli -file in -outputdir out]
end

# bad, bad code repeater!

Logger.log("\nmailing out reports\n", "\n\nall done. check your inbox") do
  reports.each do |r|
    
    teachers = r.select{|k,v| k =~ /teachers/}.values.flatten
    filename = r.select{|k,v| k !~ /teachers|size/}.values.reverse.join("_").gsub(/[\s\/]/,'_').downcase

    Logger.log("\tsending #{filename} to #{teachers.inspect}. ", 'sent.') do
      Mailer.send_mail({to: teachers.map{|t| t + mail_domain}.join(','),
                        subject: "feedback from #{r[:cohort]} on #{r[:date]}",
                        body: "the attached feedback is intended for #{teachers.join(' and ')}\n\neveryone is welcome to review it.\n\n#{mail_footer}",
                        attach: Dir.pwd + "/out/#{filename}.pdf"})
    end
  end

  Logger.log("\ncleaning up temp files...", 'all clean.') do
    %x[rm in/*]
    %x[rm out/*]
  end

end



