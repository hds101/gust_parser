class Parser
  def initialize
    init_database
  end

  def parse(browser, href, link_id)
    browser.visit href
    company_data = company(browser)
    users = []
    %w(#management #advisors #investor).each do |section|
      browser.find(section).all('li .card-title').each do |user|
        users << { href: (user.find('a')[:href] rescue nil), #TODO: rescue
                   name: user.text,
                   tags: tag(section) }
      end rescue nil #TODO: rescue
    end
    id = @db[:companies].insert(company_data.merge(link_id: link_id, href: href))
    users.each { |user|@db[:users].insert(user.merge(company_id: id)) }
  end

  private

  def tag(section)
    case section
    when '#management' then 'team'
    when '#advisors'   then 'advisors'
    when '#investor'   then 'previous_investors'
    end
  end

  def company(browser)
    data = {
      name: browser.all('#company_info h2')[0]&.text&.strip,
      slogan: browser.all('#company_info p.quote')[0]&.text&.strip,
      overview: browser.all('#company_overview .panel-body > p')[0]&.text&.strip
    }
    browser.all('#company_info ul.list-group li.list-group-item').each do |item|
      column = item.text.split[0].downcase.to_sym
      value  = item.find('span.value').text
      case column
      when :website
        value  = item.find('span.value').find('a')[:href]
      when :incorporation
        column = :incorporation_type
      end
      data[column] = value
    end
    data
  end

  # def user(browser)
  #   data = {
  #     name:     browser.find('#user_profile .profile .card-title')&.text&.strip,
  #     location: browser.find('#user_profile .profile .card-subtitle > div > span')&.text&.strip,
  #     role:     browser.find('#user_profile .profile .card-subtitle > p')&.text&.strip
  #   }
  #   bio = browser.find('#user_profile #biography .value .rest')&.text&.strip
  #   data[:biography] = bio.gsub(/Show\sLess$/, '') unless bio == 'Show Less'
  #   data
  # end

  def init_database
    @db = Sequel.connect('sqlite://db/gust.db')

    unless @db.table_exists?(:companies)
      @db.create_table :companies do
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
        Integer :employees
        String :website
        String :incorporation_type
      end
    end

    unless @db.table_exists?(:users)
      @db.create_table :users do
        primary_key :id
        Integer :company_id
        String :href
        String :name
        String :tags
        # social
      end
    end

    unless @db.table_exists?(:tags)
      @db.create_table :tags do
        primary_key :id
        String :name
      end
      %w(team advisors previous_investors).each do |tag|
        @db[:tags].insert(name: tag)
      end
    end
  end
end
