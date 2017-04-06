require 'capybara/poltergeist'

class Collector
  def initialize
    init_database
    init_capybara
    @index = 0
  end

  def loop(page='https://gust.com/search/new?category=startups')
    @browser.visit page
    @browser.find('#search_results')
            .all('.list-group-item .card-title > a')
            .each do |company_link|
      @db[:companies].insert(
        name: company_link.text,
        href: company_link[:href]
      )
    end
    @index += 1
    next_page = @browser.all('#search_results li.last').first.find('a')[:href]
    puts "Going to #{next_page}..."
    # Reset phantomjs each 200'th page
    restart_phantomjs if !@index.zero? && (@index % 200).zero?
    loop next_page
  end

  private

  def init_database
    @db = Sequel.connect('sqlite://companies2.db')
    unless @db.table_exists?(:companies)
      @db.create_table :companies do
        primary_key :id
        String :href
        String :name
        Boolean :parsed, default: false
      end
    end
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
    end
  end
end

