require 'rubygems'
require 'bundler/setup'

task :parse_companies do
  require './lib/companies_parser.rb'
  parser = CompaniesParser.new
  (7317..11868).each do |page|
    puts "== Parsing page #{page} of 11865"
    parser.parse(page)
  end
end
