require 'dotenv'
require 'set'
require_relative 'lib/input_parser'
require_relative 'lib/keep'

def validate_args(argv)
  if argv.size != 1
    return [-1, 'grocery list file path required']
  end

  input_file = argv[0]
  unless File.exist? input_file
    return [-1, "#{input_file} not found"]
  end

  return [0, nil]
end

def main(argv)
  Dotenv.load
  
  credentials = Groceries::user_credentials(
    for: ENV['USER_TO_IMPERSONATE'], 
    api_key: ENV['GOOGLE_APPLICATION_CREDENTIALS']
  )

  list = Groceries::List.new(credentials, ENV['GROCERY_LIST_NAME'])
  uniques = Set.new(list.get_items)

  new_items = parse(argv[0])

  new_items.collect { |item| uniques << item }
  puts uniques

  list.save(uniques.to_a).share_with(ENV['USER_TO_INVITE'])  
end

(err_code, err_msg) = *validate_args(ARGV)
if err_code != 0
  STDERR.puts err_msg
  exit(err_code)  
end

main(ARGV)
