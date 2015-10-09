class DatabaseMan
  class << self
    def open(db_file)
      ActiveRecord::Base.establish_connection(
        adapter: 'sqlite3',
        database: db_file
      )
    end

    def close
      ActiveRecord::Base.remove_connection
    end
  end
end