require 'googlecharts'
require 'open-uri'

require_relative 'charts.rb'

CHART_SIZE = '900x200'
CHART_PROPERTIES = '5,1,20'
COLOR = {lime:   'a4c400', green:  '60a917', emerald: '008a0',
         teal:   '00aba9', cyan:   '1ba1e2', cobalt:  '0050ef',
         indigo: '6a00ff', violet: 'aa00ff', pink:    'f472d0',
         magenta:'d80073', crimson:'a20025', red:     'e51400',
         orange: 'fa6800', amber:  'f0a30a', yellow:  'e3c800',
         brown:  '825a2c', olive:  '6d8764', steel:   '647687',
         mauve:  '76608a', taupe:  '87794e'} 

# ["fa6800", "a20025", "aa00ff"]

CHART_COLORS = COLOR.values.sample(4)

# CHART_COLORS = ["6a00ff","a20025","e3c800"]
data =  {'question1' => 
          {'cohort1' => 
            {'3/8/2013'   => 0.78,
             '3/15/2013'  => 0.8,
             '3/22/2013'  => 0.7},
           'cohort2' => 
            {'3/8/2013'   => 0.5,
             '3/15/2013'  => 0.2,
             '3/22/2013'  => 0.9},
           'cohort3' => 
            {'3/8/2013'   => 1.8,
             '3/15/2013'  => 1.2,
             '3/22/2013'  => 0.7}
          },
         'question2' => 
          {'cohort1' => 
            {'3/8/2013'   => 1.78,
             '3/15/2013'  => 2.8,
             '3/22/2013'  => 1.7},
           'cohort2' => 
            {'3/8/2013'   => 2.5,
             '3/15/2013'  => 1.2,
             '3/22/2013'  => 1.9},
           'cohort3' => 
            {'3/8/2013'   => 0.8,
             '3/15/2013'  => 1.2,
             '3/22/2013'  => 2.7}
          },         'question3' => 
          {'cohort1' => 
            {'3/8/2013'   => 1.78,
             '3/15/2013'  => 2.8,
             '3/22/2013'  => 1.7},
           'cohort2' => 
            {'3/8/2013'   => 2.5,
             '3/15/2013'  => 1.2,
             '3/22/2013'  => 1.9},
           'cohort3' => 
            {'3/8/2013'   => 0.8,
             '3/15/2013'  => 1.2,
             '3/22/2013'  => 2.7}
          }
        }

data = YAML::load(File.open('data.dump.txt'))


class Array
  def rjust(n, x); Array.new([0, n-length].max, x)+self end
  def ljust(n, x); dup.fill(x, length...n) end
end

class ChartDrawer

  def self.draw(d, chart = :bar)
    
    urls = []
    dates = []

    d.each do |q,v|

      # p URI::encode(q.text.gsub(/'/,''))
      question_text = URI::encode(q.text.gsub(/'/,''))

      cohort_data   = []
      survey_dates  = []

      cohort_names  = v.keys


      # p v
      # exit
      v.each do |c, d|
        survey_dates << d.keys.map{|date| date.gsub(/\/2013/,'')}    # only need the dates once since they repeat
        cohort_data << d.values   # the data should be unique though
      end

      survey_dates.flatten!.uniq!
      cohort_data = cohort_data.map{|series| series.rjust(survey_dates.length, nil)}

      # p cohort_names
      # p survey_dates
      # p cohort_data
      # exit
      # survey_dates  = v.map(&:values).first.flatten.map(&:keys).flatten
      
      # v.map(&:values).flatten(1).each do |c|
      #   cohort_data << c.map(&:values).flatten
      # end

      p question_text
      p cohort_names
      p survey_dates
      #cohort_data.map!{|row| row.map!{|record| record.nil? ? record : (record.zero? ? 0.01 : record)}}
      puts "-"*50
      urls << [Gchart.bar(:data       => cohort_data,     :stacked                => false,
                         :title       => question_text,   :axis_with_labels       => true,
                         :legend      => cohort_names,    :bar_width_and_spacing  => CHART_PROPERTIES,
                         :labels      => survey_dates,
                         :bar_colors  => CHART_COLORS,
                         :size        => CHART_SIZE ), cohort_data]
    end
    urls
  end
end

p CHART_COLORS

images = ChartDrawer.draw(data)

# html = images.map{|i| "<img src='#{i}'>"}.join("\n")
html = ''
images.each do |img|
  html += "<img src='#{img[0]}" + (img[1].flatten.compact.min < 0 ? '&chds=-2.0,2.0' : '') + "'>\n<pre> #{img[1].map{|e| e.join("\t  ")}.join("\n")}</pre>\n<br><br>"
end

File.open('out.htm', 'w').write(html)


# p Gchart.bar(:data => [[150,123,223, 75, 30, 12], [75,25, 300, 100, 30, 200], [82,123,100, 200, 300, 10]], 
#              :bar_colors => 'FF0000,00FF00,0000FF',
#              :stacked => false,
#              :legend => ['sea lions', 'banana slugs', 'golden bears'],
#              :size => '550x200',
#              :bar_width_and_spacing => '10,2,12'
#            )