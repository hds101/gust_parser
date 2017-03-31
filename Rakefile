require 'bundler/setup'
Bundler.require :default

# task :collect_companies do
#   require './lib/companies_parser.rb'
#   parser = CompaniesParser.new
#   (11146..11875).each do |page|
#     puts "== Parsing page #{page} of 11865"
#     parser.parse(page)
#   end
# end

task :start do
  require './lib/crawler.rb'
  require './lib/parser.rb'
  Crawler.new.start
end

task :reset do
  require './lib/crawler.rb'
  require './lib/parser.rb'
  Crawler.new.reset!
end
