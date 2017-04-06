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
      @parser.parse(@browser, company[:href], company[:id])
      print "#{index+1}/#{count}...\r"
      @db[:companies].where(id: company[:id]).update(parsed: true)
      # Reset phantomjs each 200'th record
      restart_phantomjs if !index.zero? && (index % 200).zero?
    end
  end

  def self.reset!
    File.delete 'gust.db'
    Sequel.connect('sqlite://companies.db')[:companies]
          .where(parsed: true)
          .update(parsed: false)
  end

  private

  def init_database
    @db = Sequel.connect('sqlite://companies.db')
  end

  def init_capybara
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app,
                                        js_errors: false,
                                        phantomjs_options: ['--load-images=no',
                                                            '--disk-cache=yes'])
    end
    Capybara.default_driver = :poltergeist
    @browser = Capybara.current_session
  end

  def restart_phantomjs
    Capybara.send('session_pool').each do |_, session|
      next unless session.driver.is_a?(Capybara::Poltergeist::Driver)
      session.driver.restart
      puts "Restart phantomjs: OK"
      authorize
    end
  end

  def authorize
    @browser.visit 'https://gust.com/users/sign_in'
    node = @browser.find('form.simple_form')
    node.fill_in 'user_email', with: ENV['GUSTPARSER_EMAIL']
    node.fill_in 'user_password', with: ENV['GUSTPARSER_PASSWORD']
    node.click_on 'Sign In'
    puts "Authorize: OK"
  end
end
