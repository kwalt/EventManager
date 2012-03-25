# Dependencies
require "csv"

# Class Definition
class EventManager
	INVALID_ZIPCODE = "00000"
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

end


# Script
manager = EventManager.new("./event_manager/event_attendees.csv")
#manager.print_names
#manager.print_numbers
#manager.print_zipcodes
manager.output_data("./event_manager/event_attendees_clean.csv")