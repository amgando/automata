require 'mail'
require_relative '../lib/feedback'

######################################################################
#
#  Driver Code
#
######################################################################

TEACHER_SURVEY = "0Ag1udyiPyRNrdGtkbFF2MUtfTVlweDROTVRPVlRfV2c"
# other spreadsheets here using their key from the URL
#   for example: URL?key=0Ag1udyiPyRNrdFBkcVFyNFlDUjlkZE9nbWY3a2h4MUE

time = Time.new
date = "%s/%s" % [time.month, time.day]

# first run.  yay!
# reports = [{date: "3/8",  cohort: "Sea Lions",    teachers: %w[jeffrey shadi]}, 
#            {date: "3/15", cohort: "Sea Lions",    teachers: %w[jesse shadi]},
#            {date: "3/8",  cohort: "Banana Slugs", teachers: %w[brick anne]}, 
#            {date: "3/15", cohort: "Banana Slugs", teachers: %w[jeffrey anne]},
#            {date: "3/15", cohort: "Golden Bears", teachers: %w[brick zee]}]

# this is real data

reports = ['Anne Spalding', 'Brick Thornton',
			]

reports = [{date: date, cohort: "Sea Lions",    teachers: %w[jesse shadi]},
           {date: date, cohort: "Banana Slugs", teachers: %w[jeffrey anne]},
           {date: date, cohort: "Golden Bears", teachers: %w[brick zee]}]

# this is fake data
reports = [{date: date,   cohort: "Sea Lions",    teachers: %w[sherif]}]


mail_domain = '@devbootcamp.com'
mail_footer = 'please note that the data in these reports is only as good as the data we have.  any student giving feedback with the wrong cohort has to be fixed in the original google spreadsheet.'

feedback = Feedback.load_feedback_from_document(WEEKLY_RETRO)

Logger.log("generating reports as markdown...\n", '') do
  reports.each do |r|
    # teachers = r.select{|k,v| k =~ /teachers/}.values
    filename = r.select{|k,v| k !~ /teachers/}.values.reverse.join("_").gsub(/[\s\/]/,'_').downcase
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
    filename = r.select{|k,v| k !~ /teachers/}.values.reverse.join("_").gsub(/[\s\/]/,'_').downcase

    Logger.log("\tsending #{filename} to #{teachers.inspect}. ", 'sent.') do
      Mail.deliver do
        delivery_method :smtp, 
                        { address: "smtp.gmail.com", port: 587, 
                          domain: 'devbootcamp.com',
                          user_name: 'sherif@devbootcamp.com',
                          password: PASSWORD,
                          enable_starttls_auto: true}
        from    'sherif@devbootcamp.com'
        to      teachers.map{|t| t + mail_domain}.join(',')
        cc      'sf@devbootcamp.com, sherif@devbootcamp.com'
        subject "feedback from #{r[:cohort]} on #{r[:date]}"
        body    "the attached feedback is intended for #{teachers.join(' and ')}\n\neveryone is welcome to review it.\n\n#{mail_footer}"
        add_file Dir.pwd + "/out/#{filename}.pdf"
      end
    end
  end

  Logger.log("\ncleaning up temp files...", 'all clean.') do
    %x[rm in/*]
    %x[rm out/*]
  end

end



