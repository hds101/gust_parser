require 'capybara/poltergeist'
require 'sequel'

class CompaniesParser
  ACCOUNT = { email: ENV['GUSTPARSER_EMAIL'],
              password: ENV['GUSTPARSER_PASSWORD'] }
  LOGIN_URI = 'https://gust.com/users/sign_in'
  SEARCH_URI = 'https://gust.com/search/new?category=startups'

  def initialize
    init_database
    init_capybara
    authorize
  end

  def parse(page)
    @browser.visit("#{SEARCH_URI}&page=#{page}")
    companies_node = @browser.find('#search_results')
    links = []
    companies_node.all('.list-group-item .card-title > a').each do |company_link|
      @db[:companies].insert(
        name: company_link.text,
        href: company_link['href']
      )
    end
    @browser.driver.clear_memory_cache
  end

  private

  def init_capybara
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, js_errors: false)
    end
    Capybara.default_driver = :poltergeist
    @browser = Capybara.current_session
  end

  def init_database
    @db = Sequel.connect('sqlite://companies.db')
    unless @db.table_exists?(:companies)
      @db.create_table :companies do
        primary_key :id
        String :href
        String :name
        Boolean :parsed, default: false
      end
    end
  end

  def authorize
    @browser.visit LOGIN_URI
    node = @browser.find('form.simple_form')
    node.fill_in 'user_email', with: ACCOUNT[:email]
    node.fill_in 'user_password', with: ACCOUNT[:password]
    node.click_on 'Sign In'
  end
end
