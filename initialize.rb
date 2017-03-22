require 'sequel'

db = Sequel.connect('sqlite://gust.db')

db.create_table :companies do
  primary_key :id
  Integer :link_id
  String :href
  String :name
  Text :slogan
  Text :overview
  String :stage
  String :industry
  String :location
  String :currency
  String :founded
  String :employees
  String :website
end

db.create_table :users do
  primary_key :id
  Integer :company_id
  String :company_role
  String :href
  String :name
  String :location
  String :role
  Text :biography
  # social
end
