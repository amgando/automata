require "google_drive"

PASSWORD = ''

class FeedbackEntry

  attr_accessor :date,
                :structure, :feedback, :attention, :speaker,
                :enjoyment, :balance, :pace, :learning, :edge,
                :my_effort, :my_integrity, :my_kindness,
                :other_effort, :other_integrity, :other_kindness,
                :comment, :name, :cohort

  COLUMNS = {:date => "Timestamp",
             :structure => "How was the looseness / tightness of the structure for you this week?",
             :feedback => "I learned / practiced giving and getting feedback this week.",
             :attention => "I got the personal attention I needed this week.",
             :speaker => "I benefited from the speaker(s) talk(s) this week.",
             :enjoyment => "I enjoyed myself this week.",
             :balance => "How was the code / talk balance this week?",
             :pace => "How as the pace of learning for you this week?",
             :learning => "I learned a lot this week.",
             :edge => "I spent most of the week in my:",
             :my_effort => "I'm putting in all my effort.",
             :my_integrity => "I'm showing up in integrity.",
             :my_kindness => "I'm showing up with kindness.",
             :other_effort => "Others are putting in all their effort.",
             :other_integrity => "Others are showing up in integrity.",
             :other_kindness => "Others are showing up in kindness.",
             :comment => "Anything else?",
             :name => "Name",
             :cohort => "Cohort"
             }


  def initialize(args)
    @date = args[:date]
    @comment = args[:comment]
    @cohort = args[:cohort]
    @name = args[:name]
  end
end

class Feedback

  def initialize
    @@entries = []
  end

  def self.load_feedback_from_document(document_key)

    ws = nil

    Logger.log("opening session with google...",'') do

      begin
        session = GoogleDrive.login("sherif@devbootcamp.com", PASSWORD)
      rescue GoogleDrive::AuthenticationError => error
        Logger.log(error)
        exit
      end
      Logger.log("grabbing a reference to the retro worksheet...") do
        ws = session.spreadsheet_by_key(WEEKLY_RETRO).worksheets[0]
      end
    end 

    feedback = self.new

    # print "found #{arr.length - 1} rows. processing..."

    Logger.log("generating new entries from #{ws.rows.count} rows.") do
      ws.rows[1..-1].each do |row|
        @@entries << FeedbackEntry.new(date: row[0],
                         comment: row["Q".ord - "A".ord],
                         name: row["R".ord - "A".ord],
                         cohort: row["S".ord - "A".ord])

        # Logger.log("processed #{@@entries.count} rows.")

      end
    end
    feedback
  end


  # usage: Feedback#all(:date => DATE | :cohort => COHORT) as filters
  def all(args = nil)
    return @@entries if args.nil?

    # setup results after filters
    retval = @@entries

    # filter on date
    if args[:date]
      retval = retval.select{|e| e.date =~ /#{Regexp.quote(args[:date])}/ }
    end

    # filter on cohort
    if args[:cohort]
      retval = retval.select{|e| e.cohort =~ /#{Regexp.quote(args[:cohort])}/}
    end

    # return filtered results
    Logger.log("\tfiltered total down to #{retval.length} records.")
    retval
  end
end

class FeedbackViewer

  def self.render(entries, header)

    formatted_entries = []

    entries.each do |e|
      entry = ''
      entry += '**' + (e.name.strip.empty? ? 'Anonymous Coward' : e.name.strip) + '**'
      entry += "\n\n"
      entry += (e.comment.strip.empty? ? 'no comment' : e.comment.strip)
      formatted_entries << entry
    end

    # md_entries = entries.map{|e| "**#{e.name == '' ? 'Anonymous Coward' : e.name}**\n\n#{e.comment}"}   

    out = <<MARKDOWN
# Feedback

## #{header[:date]} - #{header[:cohort]}

(found #{entries.count} responses out of #{header[:size]} expected)


#{formatted_entries.join("\n\n---\n\n")}

MARKDOWN
    out
  end
end

class Mailer

  def self.send_mail(args)
      Mail.deliver do
        delivery_method :smtp, 
                        { address: "smtp.gmail.com", port: 587, 
                          domain: 'devbootcamp.com',
                          user_name: 'sherif@devbootcamp.com',
                          password: PASSWORD,
                          enable_starttls_auto: true}
        from     'sherif@devbootcamp.com'
        to       args[:to]
        cc       'sf@devbootcamp.com, sherif@devbootcamp.com'
        subject  args[:subject]
        body     args[:body]
        add_file args[:attach]
      end
  end
end




class Logger
  def self.log(before_msg, after_msg = ' done.')
    print before_msg
    yield if block_given?
    puts after_msg
  end
end