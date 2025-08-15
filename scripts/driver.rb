require 'dotenv'
require 'set'
require_relative 'lib/input_parser'
require_relative 'lib/keep'

Dotenv.load

credentials = Groceries::user_credentials(
  for: ENV['USER_TO_IMPERSONATE'], 
  api_key: ENV['GOOGLE_APPLICATION_CREDENTIALS']
)

list = Groceries::List.new(credentials, ENV['GROCERY_LIST_NAME'])
uniques = Set.new(list.get_items)

# TODO actually get items from input file
new_items = ['Tomatoes', 'Apples', 'Bananas']

new_items.collect { |item| uniques << item }
puts uniques

list.save(uniques.to_a).share_with(ENV['USER_TO_INVITE'])