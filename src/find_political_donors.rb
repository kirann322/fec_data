# find_political_donors.rb takes an input file of FEC inidividual campaign contribution data and processes it into 2 output files,
# the first of which is sorted by zip, and the second of which is sorted by date

# inputs following find_political_donors.rb in the shell script
# ARGV[0] is the first input, ARGV[1] is the second input, ARGV[2] is the third input
# pulls name of first input of shell script (input file, "itcont.txt")
FILENAME = ARGV[0]
# pulls name of second input of shell script (first output file, "medianvals_by_zip.txt")
ZIP_OUT = ARGV[1]
# pulls name of third input of shell script (second output file, "medianvals_by_date.txt")
DATE_OUT = ARGV[2]

# initializes the position indices of each element of relevant data in the input file as constants
CMTE_ID = 0
ZIP = 10
DATE = 13
AMOUNT = 14
OTHER_ID = 15

# prime number used for hash function
HASH_PRIME = 24593

# creates a class defining specific pairs of data, reading in a key object, defined below
class Paired_ID_data
  
  attr_reader :key
    
    # total number of transaction from that specific key
    @num
    # total value amount of transactions from that specific key
    @total
    # array of all donations from that specific key
    @all_donations
  
    # initializes a specific paired_id_data object given a key
    def initialize key
      # assigns key as the given value
      @key = key
      # creates an empty array
      @all_donations = []
      # starts the number of donations at 0
      @num = 0
      # starts the total value of donations at 0
      @total = 0 
    end
  
    # function that adds the next contribution to the running list of donations for a given (id,zip) or (id,date) pair
    # sorts and keeps sorted the array of donations that correspond to a specific (id,zip) or (id,date) pair
    def add_sorted item
        # adds the item to the back of the array 
        # array length increases by 1, index of item is length - 1
        @all_donations << item
        # selects the index before the index of item (length - 1)
        # previously largest value in array was length - 2
        index = @all_donations.length - 2
        # while the value of the data in front of item is greater
        # and we have not hit the front bound of the array
        # replace the largest value with the smaller one and move forward
        while @all_donations[index] > item && index >= 0 do
          @all_donations[index + 1] = @all_donations[index]
          index -= 1
        end 
        # set the value of the properly indexed position to item
        @all_donations[index + 1] = item
    end
  
    # calculates the median for the set of data associated with a specific (id,zip) or (id,date) pair
    def get_median
      # checks if the length of all_donations is even (if) or odd (else)
      if @all_donations.length % 2 == 0 then
        # finds the middle index of the array
        mid = (@all_donations.length / 2)
        # calculates the median value as the average of the 2 middle values
        median = ((@all_donations[mid] + @all_donations[mid - 1]) / 2)
      else
        # finds the middle index of the array
        mid = (@all_donations.length / 2)
        # calculates median value as the middle value (due to index starting at 0 and truncated decimal after division)
        median = @all_donations[mid]
      end
      # rounds the median value
      return median.round
    end
    
    # updates the median, num, and total donations per data pair
    def update donation
      # increases the total number of donations by 1
      @num += 1
      # increases the total value amount of donations by the amount of the most recent donation
      @total += donation
      # adds the donation information into the array of donations
      self.add_sorted donation  
    end
    
    # converts the key into a printable string id|zip|median|num|total \n
    def to_s
      @key.to_s + "|" + self.get_median.to_i.to_s + "|" + @num.to_s + "|" + @total.to_i.to_s + "\n"
    end
      
end

# creates a specific key object to reference each pair of data (id,zip) or (id,date)
class Key
  
  attr_reader :id
  attr_reader :paired
    
  # initializes a key from an id and paired
  # paired is a placeholder for either a date or zip input
  def initialize id, paired
    @id = id
    @paired = paired
  end
  
  # checks for equality between 2 different keys
  def eql? other
    @id == other.id && @paired == other.paired
  end
  
  # defines the hash function used to index each key
  def hash
    a = 0
    @id.each_byte {|c| a += c.to_i}
    (a + @paired.to_i) * HASH_PRIME
  end
  
  # creates a printable string from the id and selected paired data
  def to_s
    @id + "|" + @paired
  end
  
end

# declares two hashmaps that take Key objects (representing a pair of some CMTE_ID and either a date or a zip) and maps them to
# Paired_ID_data objects (which hold information about the transactions associated with each ID/zip or ID/date pair)
# When queried, maps either return false (if the Key has not been seen) or the Paired_ID_data object (which evaluates to true)
seen_zip = Hash.new(false)
seen_date = Hash.new(false)

# open an output file
File.open(ZIP_OUT, 'w') { |output|
  
# makes a Data object for each line in the file, then begins to process it
File.open(FILENAME).each do |line|

  # splits the line on the delimiter
  parsed_line = line.split(/\|/)
  
  # checks if CMTE_ID is empty, if AMOUNT is malformed, or if OTHER_ID is non-empty, and if so jumps to next line in loop
  # regular expression (regex) allows for 0/1 leading minus sign, any number of digits, 0/1 decimal point, up to 2 digits
  if parsed_line[OTHER_ID] != "" || 
     parsed_line[CMTE_ID] == "" ||
     !parsed_line[AMOUNT].match(/^-?\d+\.?\d{0,2}$/) 
  then
     next
  else
    # checking zip and date for malformations
    # regex allows minimum of 5 digits for zip, otherwise flags as bad (malformed)
    if parsed_line[ZIP].match(/^\d{5,}$/) then bad_zip = false else bad_zip = true end
      
    # regex allows only 8 digits for date, otherwise flags as bad (malformed)
    if parsed_line[DATE].match(/^\d{8}$/) then bad_date = false else bad_date = true end
      
    # gets cmte_id from the scanned line from position 0
    cmte_id = parsed_line[CMTE_ID]
    
    # checks for a bad zip, and if not, gets the zip from position 10 and truncates at 5 digits
    if !bad_zip then zip = (parsed_line[ZIP])[0..4] end
      
    # checks for a bad date, and if not, gets the date from position 13
    if !bad_date then date = parsed_line[DATE] end
      
    # gets the donation amount from position 14, and then converts the amount into a float
    amount = parsed_line[AMOUNT].to_f
  
    # checks for a bad zip, and if not, proceeds
    if (!bad_zip) then
      # creates a new key for this combination of id and zip
      zip_key = Key.new cmte_id, zip
      # checks if the key has been seen before    
      if seen_zip[zip_key] then
        # runs the update function
        seen_zip[zip_key].update amount
      else
        # creates a new Paired_ID_data object using the current key
        seen_zip[zip_key] = Paired_ID_data.new zip_key
        # runs the update function
        seen_zip[zip_key].update amount
      end
      # writes output to the streamed zip data file "medianvals_by_zip.txt" by default
      output.write(seen_zip[zip_key])
    end
    
    #checks for a bad date, if not, proceeds
    if (!bad_date) then
      # creates a new key for this combination of id and zip
      date_key = Key.new cmte_id, date
      # checks if the key has been seen before
      if seen_date[date_key] then
        # runs the update function
        seen_date[date_key].update amount
      else
        #creates a new Paired_ID_data object using the current key
        seen_date[date_key] = Paired_ID_data.new date_key
        # runs the update function
        seen_date[date_key].update amount
      end
    end
    
  end
end   
}                   

#create the output for the date file "medianvals_by_date.txt" by default
File.open(DATE_OUT, 'w') { |output|
  seen_date.each { |key, val|
    output.write(val)
    }  
}
