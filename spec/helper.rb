require 'pathname'
require 'pp'
Dir[Pathname.new("#{__dir__}") + '../app/configuration.rb'].each { |f| require f }
Dir[Pathname.new("#{__dir__}") + './supports/**/*.rb'].each { |f| require f }

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'test_db'
)

