require 'mechanize'

module GustParser
  class Fetcher
    def initialize(page)
      @page = page
    end

    def company
      company = { users: [] }
      company[:name] = @page.search('#company_info h2')[0]&.text
      company
    end

    def user
      user = { contacts: [] }
      user[:name] = @page.search('#user_profile .profile .card-title')[0]&.text
      user[:location] = @page.search('#user_profile .profile .card-subtitle > div > span')[0]&.text
      user[:role] = @page.search('#user_profile .profile .card-subtitle > p')[0]&.text
      # @page.search('#user_profile .contact-information .value')
      user
    end
  end
end
