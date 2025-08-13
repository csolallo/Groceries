CONJUNCTIONS = ['and', 'or']

# params
#   file: file with grocery items copied from device
# return 
#   comma separated list of grocery items
def parse(file)
  grocery_items = File.open(file, "r") do |f|
    items = []
    
    # split on newlines
    lines = f.readlines
    lines.each do |line|
      line.chomp!

      # split on commas
      words = line.split(',')
      words.each do |word|

        # split on conjunctions
        regexp_fragments = CONJUNCTIONS.inject([]) { |arr, conj| arr << %r{\s*#{conj}\s+}i }
        item = word.split(Regexp.union(*regexp_fragments))
        item.each do |w| 
          w.strip!
          items << w unless w.size == 0     
        end
      end 
    end 
    f.close
    items
  end
  return grocery_items
end
