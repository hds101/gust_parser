require 'mechanize'
require 'sequel'

module GustParser
  class Fetcher
    def initialize(page)
      @page = page
      @db = Sequel.connect('sqlite://gust.db')
    end

    def company
      companies = @db[:companies]
      id = companies.insert(
        name: @page.search('#company_info h2')[0]&.text&.strip,
        slogan: @page.search('#company_info p.quote')[0]&.text&.strip,
        overview: @page.search('#company_overview .panel-body > p')[0]&.text&.strip
      )
    end

    def user(company_id)
      bio = @page.search('#user_profile #biography .value .active > p')[0]&.text&.strip
      # @page.search('#user_profile .contact-information .value')
      users = @db[:users]
      id = users.insert(
        company_id: company_id,
        name: @page.search('#user_profile .profile .card-title')[0]&.text&.strip,
        location: @page.search('#user_profile .profile .card-subtitle > div > span')[0]&.text&.strip,
        role: @page.search('#user_profile .profile .card-subtitle > p')[0]&.text&.strip,
        biography: (bio == 'Show Less' ? nil : bio.gsub(/Show\sLess$/, ''))
      )
    end
  end
end
