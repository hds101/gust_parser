class Parser
  def initialize
    init_database
  end

  def parse(browser, href, link_id)
    page = browser.visit href
    id = @db[:companies].insert(
      link_id: link_id,
      name: browser.all('#company_info h2')[0]&.text&.strip,
      slogan: browser.all('#company_info p.quote')[0]&.text&.strip,
      overview: browser.all('#company_overview .panel-body > p')[0]&.text&.strip
    )
  end

  # def user(company_id)
  #   bio = @page.search('#user_profile #biography .value .active > p')[0]&.text&.strip
  #   # @page.search('#user_profile .contact-information .value')
  #   users = @db[:users]
  #   id = users.insert(
  #     company_id: company_id,
  #     name: @page.search('#user_profile .profile .card-title')[0]&.text&.strip,
  #     location: @page.search('#user_profile .profile .card-subtitle > div > span')[0]&.text&.strip,
  #     role: @page.search('#user_profile .profile .card-subtitle > p')[0]&.text&.strip,
  #     biography: (bio == 'Show Less' ? nil : bio.gsub(/Show\sLess$/, ''))
  #   )
  # end

  private

  def init_database
    @db = Sequel.connect('sqlite://gust.db')

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
        String :employees
        String :website
      end
    end

    unless @db.table_exists?(:users)
      @db.create_table :users do
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
    end
  end
end
