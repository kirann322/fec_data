# version notes
# changed get_median function, changed add_sorted to swap, changed any_malformed? function
# commented lines 114-118
# changed class names
# added checks for malformed array

# constant for filename
#FILENAME = "small_input.txt"
#ZIP_OUT = "medianvals_by_zip.txt"
#DATE_OUT = "medianvals_by_date.txt"

FILENAME = ARGV[0]
ZIP_OUT = ARGV[1]
DATE_OUT = ARGV[2]

# initialize variable indices as constants
CMTE_ID = 0
ZIP = 10
DATE = 13
AMOUNT = 14
OTHER_ID = 15

HASH_PRIME = 24593

class Paired_ID_data
  attr_reader :key
  
    @num
    @total
    @all_donations
  
    def initialize key
  
      @key = key
  
      @all_donations = []
      @num = 0
      @total = 0
      
    end
  
    def add_sorted item
    
        # we know our array is already sorted
        
        # adds the item to the back of the array
        @all_donations << item
        
        # inserts it into the correct location
        index = @all_donations.length - 2
        
        while @all_donations[index] > item && index >= 0 do
          @all_donations[index + 1] = @all_donations[index]
          index -= 1
        end
        
        @all_donations[index + 1] = item
    end
  
    def get_median
    
      if @all_donations.length % 2 == 0 then
        mid = (@all_donations.length / 2)
        median = ((@all_donations[mid] + @all_donations[mid - 1]) / 2)
      else
        mid = (@all_donations.length / 2)
        median = @all_donations[mid]
      end
      
      return median.round
    
    end
    
    def update donation
  
      @num += 1
      @total += donation
      self.add_sorted donation
          
    end
    
    def to_s
      @key.to_s + "|" + self.get_median.to_i.to_s + "|" + @num.to_s + "|" + @total.to_i.to_s + "\n"
    end  
end

class Key
  
  attr_reader :id
  attr_reader :paired
    
  def initialize id, paired
    @id = id
    @paired = paired
  end
  
  def eql? other
    @id == other.id && @paired == other.paired
  end
  
  def hash
    a = 0
    @id.each_byte {|c| a += c.to_i}
    (a + @paired.to_i) * HASH_PRIME
  end
      
  def to_s
    @id + "|" + @paired
  end
  
end



# global variables for <>sdfsdfsfsdf

# maps Z_Combos to boolean values representing if it has been encountered before
seen_zip = Hash.new(false)
seen_date = Hash.new(false)

# open an output file
File.open(ZIP_OUT, 'w') { |output|
  
# makes a Data object for each line in the file, then processes it
File.open(FILENAME).each do |line|

  # splits the line on the delimiter
  parsed_line = line.split(/\|/)
  
  # if CMTE_ID or AMOUNT are malformed, or if OTHER_ID is non-empty, skips the current line
  if parsed_line[OTHER_ID] != "" || 
     parsed_line[CMTE_ID] == "" ||
     !parsed_line[AMOUNT].match(/^-?\d+.?\d{0,2}$/) 
  then
     next
  else
    
    # <>
    if parsed_line[ZIP].match(/^\d{5,}$/) then bad_zip = false else bad_zip = true end
    if parsed_line[DATE].match(/^\d{8}$/) then bad_date = false else bad_date = true end
      
    cmte_id = parsed_line[CMTE_ID]
    if !bad_zip then zip = (parsed_line[ZIP])[0..4] end
    if !bad_date then date = parsed_line[DATE] end
    amount = parsed_line[AMOUNT].to_f
  
    if (!bad_zip) then
      
      zip_key = Key.new cmte_id, zip
          
      if seen_zip[zip_key] then
        # updates amount
        seen_zip[zip_key].update amount
      else
        seen_zip[zip_key] = Paired_ID_data.new zip_key
        seen_zip[zip_key].update amount
      end
      
      output.write(seen_zip[zip_key])
    end
  
    if (!bad_date) then
      
      date_key = Key.new cmte_id, date
      
      if seen_date[date_key] then
        # updates amount
        seen_date[date_key].update amount
      else
        seen_date[date_key] = Paired_ID_data.new date_key
        seen_date[date_key].update amount
      end
    end
    
  end
end   
}                   

#final output
File.open(DATE_OUT, 'w') { |output|
  seen_date.each { |key, val|
    output.write(val)
    }  
}
  
