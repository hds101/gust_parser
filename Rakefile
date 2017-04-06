require 'bundler/setup'
Bundler.require :default
Dir["./lib/*.rb"].each {|file| require file }

desc 'Collect all companies to companies.db'
task :collect do
  Collector.new.loop
end

desc 'Parse companies from companies.db to gust.db'
task :start do
  Crawler.new.start
end

desc 'Remove gust.db and reset all companies in companies.db'
task :reset do
  Crawler.reset!
end
