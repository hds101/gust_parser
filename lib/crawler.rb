require 'capybara/poltergeist'
require 'logger'

class Crawler
  def initialize
    init_logger
    init_database
    init_capybara
    authorize
    @parser = Parser.new
  end

  def start
    @logger.warn(">>>>> Start parsing at #{Time.now}")
    collection = @db[:companies].where(parsed: false)
    collection.each_with_index do |company, index|
      @logger.info("#{index} #{company[:href]}")
      @parser.parse(@browser, company[:href], company[:id])
      @db[:companies].where(id: company[:id]).update(parsed: true)
      break 'terminate' if index == 200
      # We need to restart phantomjs because it cause OOM on server
      # TODO: Find a way to get rid of this
      restart_phantomjs if !index.zero? && (index % 50).zero?
    end
    @logger.warn(">>>>> SUCCESS")
  rescue
    @logger.fatal($!)
    raise $!
  end

  def self.reset!
    File.delete './log/crawler.log' if File.exists? './log/crawler.log'
    File.delete './db/gust.db'      if File.exists? './db/gust.db'
    Sequel.connect('sqlite://db/companies.db')[:companies]
          .where(parsed: true)
          .update(parsed: false)
  end

  private

  def init_logger
    @logger = Logger.new('./log/crawler.log', File::APPEND)
    @logger.level = Logger::INFO
  end

  def init_database
    @db = Sequel.connect('sqlite://db/companies.db')
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
      @logger.warn('>>>>> Restarted phantomjs')
      authorize
    end
  end

  def authorize
    @browser.visit 'https://gust.com/users/sign_in'
    node = @browser.find('form.simple_form')
    node.fill_in 'user_email', with: ENV['GUSTPARSER_EMAIL']
    node.fill_in 'user_password', with: ENV['GUSTPARSER_PASSWORD']
    node.click_on 'Sign In'
    @logger.warn('>>>>> Authorized')
  end
end
