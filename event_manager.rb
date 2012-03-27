# Dependencies
require "csv"
require "sunlight"

# Class Definition
class EventManager
	INVALID_ZIPCODE = "00000"
  Sunlight::Base.api_key = "e179a6973728c4dd3fb1204283aaccb5"
  def initialize(filename)
    puts "EventManager Initialized."
    @file = CSV.open(filename, {:headers => true, :header_converters => :symbol})
  end

	def print_names
		@file.each do |line|
			#puts line[2, 2]
			#puts line[2] + " " + line[3]
			puts "#{line[:first_name]} #{line[:last_name]}"
			#puts line.inspect
		end
	end

	def clean_number(original)
		number = original.delete(".")
		number = number.delete("-")
		number = number.delete("(")
		number = number.delete(")")
		number = number.delete(" ")

		if number.length == 10
		  # Do Nothing
		elsif number.length == 11
		  if number.start_with?("1")
		    number = number[1..-1]
		  else
		    number = "0000000000"
		  end
		else
		  number = "0000000000"
		end

		return number #when I didn't have this earlier, print_numbers was
		#only printing out the few numbers that had second-round cleaning
		#But why not just put this under if number.length == 10???
	end

	def print_numbers
		@file.each do |line|
			number = clean_number(line[:homephone])
			puts number
		end
	end

	def clean_zipcode(original)
		if original.nil?
			zipcode = INVALID_ZIPCODE
		elsif original.length < 5
			zipcode = original
			while zipcode.length < 5
				zipcode = "0" + zipcode
			end
			return zipcode	
		else
			zipcode = original
		end
	end

	def print_zipcodes
		@file.each do |line|
			zipcode = clean_zipcode(line[:zipcode])
			puts zipcode
		end
	end

  def output_data(filename)
    output = CSV.open(filename, "w")
    @file.each do |line|
    	if @file.lineno == 2
    		output << line.headers
      end
      line[:homephone] = clean_number(line[:homephone])
      line[:zipcode] = clean_zipcode(line[:zipcode])
      output << line
    end
  end

  def rep_lookup
  	20.times do
  		line = @file.readline

  		representative = "unknown"
  		#API Lookup goes here
  		legislators = Sunlight::Legislator.all_in_zipcode(clean_zipcode(line[:zipcode]))
			# legislators.each do |leg|
			# 	puts leg.firstname
			#end
			names = legislators.collect do |leg|
			  #first_name = leg.firstname
			  #first_initial = first_name[0]
			  first_initial = leg.first_name[0] #why not do it this way?
			  last_name = leg.lastname
			  party_initial = leg.party
			  first_initial + ". " + last_name + "(" + party_initial + ")"
			end

			puts "#{line[:last_name]}, #{line[:first_name]}, #{line[:zipcode]}, #{names.join(", ")}"
  	end
  end

  def create_form_letters
    letter = File.open("./event_manager/form_letter.html", "r").read
    20.times do
      line = @file.readline

      custom_letter = letter.gsub("#first_name","#{line[:first_name]}")
			custom_letter = custom_letter.gsub("#last_name","#{line[:last_name]}")
			custom_letter = custom_letter.gsub("#street","#{line[:street]}")
			custom_letter = custom_letter.gsub("#city","#{line[:city]}")
			custom_letter = custom_letter.gsub("#state","#{line[:state]}")
			custom_letter = custom_letter.gsub("#zipcode","#{line[:zipcode]}")
			
			filename = "./event_manager/output/thanks_#{line[:last_name]}_#{line[:first_name]}.html"
			output = File.new(filename, "w")
			output.write(custom_letter)
		end
  end

  def rank_times
    hours = Array.new(24){0}
    @file.each do |line|
      regdate = line[:regdate]
      hour = regdate.split(" ")[1].split(":")[0]
			hours[hour.to_i] = hours[hour.to_i] + 1

    end
    hours.each_with_index{|counter,hour| puts "#{hour}\t#{counter}"}
  end

  def day_stats
  	days = Array.new(7){0}
  	@file.each do |line|
  		numerals = line[:regdate].split(" ")[0]
  		date = Date.strptime(numerals, "%m/%d/%Y")
  		day_of_week = date.wday
  		days[day_of_week.to_i] = days[day_of_week.to_i] + 1
  	end
  	days.each_with_index{|counter,day_of_week| puts "#{day_of_week}\t#{counter}"}
  end

  def state_stats
    state_data = {}
    @file.each do |line|

    end
  end


end


# Script
manager = EventManager.new("./event_manager/event_attendees_clean.csv")
#manager.print_names
#manager.print_numbers
#manager.print_zipcodes
#manager.output_data("./event_manager/event_attendees_clean.csv")
#manager.rep_lookup
#manager.create_form_letters
#manager.rank_times
manager.day_stats