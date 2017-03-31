require 'capybara/poltergeist'

class Crawler
  def initialize
    init_database
    init_capybara
    authorize
    @parser = Parser.new
  end


  def start
    collection = @db[:companies].where(parsed: false)
    count = collection.count
    collection.each_with_index do |company, index|
      break if index == 1999
      @parser.parse(@browser, company[:href], company[:id])
      print "#{index+1}/#{count}...\r"
      @db[:companies].where(id: company[:id]).update(parsed: true)
      # Reset the session each 100'th record
      if (index % 100).zero?
        @browser.driver.clear_memory_cache
        Capybara.reset_sessions!
        @browser = Capybara.current_session
      end
    end
  end

  def reset!
    @db[:companies].where(parsed: true).update(parsed: false)
  end

  private

  def init_database
    @db = Sequel.connect('sqlite://companies.db')
  end

  def init_capybara
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, js_errors: false)
    end
    Capybara.default_driver = :poltergeist
    @browser = Capybara.current_session
  end

  def authorize
    @browser.visit 'https://gust.com/users/sign_in'
    node = @browser.find('form.simple_form')
    node.fill_in 'user_email', with: ENV['GUSTPARSER_EMAIL']
    node.fill_in 'user_password', with: ENV['GUSTPARSER_PASSWORD']
    node.click_on 'Sign In'
  end
end
