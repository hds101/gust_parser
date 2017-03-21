require 'mechanize'
require 'pry'

module GustParser
  class Crawler
    ACCOUNT = { email: ENV['GUSTPARSER_EMAIL'],
                password: ENV['GUSTPARSER_PASSWORD'] }
    LOGIN_URI = 'https://gust.com/users/sign_in'
    SEARCH_URI = 'https://gust.com/search/new?utf8=✓&category=startups&' \
                 'keywords[]=&list_change_data={"filter_type":"category",' \
                 '"filter_value":"startups","event_type":"filtered"}'

    def initialize
      @agent = ::Mechanize.new
      authorize!
    end

    def parse
      result = []
      companies_links(@agent.get(SEARCH_URI)).each do |company_link|
        company_page = company_link.click
        data = Fetcher.new(company_page).company
        users_links(company_page).each do |user_link|
          user_page = user_link.click
          data[:users] << Fetcher.new(user_page).user
          sleep 2
        end
        result << data
        sleep 2
      end
      pp result
    end

    private

    def companies_links(page)
      page.links.select do |link|
        link.href.nil? ? false : link.href[/^\/companies/] && !link.href[/\/dashboard$/]
      end
    end

    def users_links(page)
      page.links.select do |l|
        l.href.nil? ? false : l.href[/^\/user\//] && l.text != 'Profile'
      end
    end

    def authorize!
      sign_in_page = @agent.get(LOGIN_URI)
      form = sign_in_page.form()
      form.field_with(name: 'user[email]').value = ACCOUNT[:email]
      form.field_with(name: 'user[password]').value = ACCOUNT[:password]
      form.submit()
    end
  end
end
