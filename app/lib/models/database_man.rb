class DatabaseMan
  class << self
    def ready(db_file)
      ActiveRecord::Base.establish_connection(
        adapter: 'sqlite3',
        database: db_file
      )
    end
  end
end