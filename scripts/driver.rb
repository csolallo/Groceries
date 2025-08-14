require 'dotenv'
require_relative 'lib/input_parser'
require_relative 'lib/keep'

Dotenv.load
puts "Key Path: #{ENV['GOOGLE_APPLICATION_CREDENTIALS']}"
