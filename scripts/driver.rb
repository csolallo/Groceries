require 'dotenv'
require_relative 'lib/input_parser'
require_relative 'lib/keep'

Dotenv.load

credentials = Groceries::user_credentials(
  for: ENV['USER_TO_IMPERSONATE'], 
  api_key: ENV['GOOGLE_APPLICATION_CREDENTIALS']
)

list = Groceries::List.new(credentials, ENV['GROCERY_LIST_NAME'])
list.save(['Tomatoes', 'Apples', 'Bananas'])

list = Groceries::List.new(credentials, ENV['GROCERY_LIST_NAME'])
items = list.get_items
puts items