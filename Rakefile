require 'rubygems'
require 'bundler/setup'

task :parse_companies do
  require './lib/companies_parser.rb'
  parser = CompaniesParser.new
  (1643..11859).each do |page|
    puts "== Parsing page #{page} of 11859"
    parser.parse(page)
  end
end
