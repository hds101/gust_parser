require 'rubygems'
require 'bundler/setup'

task :parse_companies do
  require './lib/companies_parser.rb'
  parser = CompaniesParser.new
  (8806..11873).each do |page|
    puts "== Parsing page #{page} of 11865"
    parser.parse(page)
  end
end
