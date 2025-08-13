# params
#   file: file with grocery items copied from device
# return 
#   comma separated list of grocery items
def parse(file)
  grocery_items = File.open(file, "r") do |f|
    lines = f.readlines
    items = []
    lines.each { |line| items << line }
    f.close
    items
  end
  return grocery_items
end
