require 'pathname'

Dir[
  Pathname.new("#{__dir__}") + '../app/app.rb',
  Pathname.new("#{__dir__}") + './supports/**/*.rb'
].each(&method(:require))

Logger.work!

analysed_config = Analyst.new('spec/fixtures', valid_hash).analyse.config
LiaisonApplication.build_database(analysed_config)
DatabaseMan.open(analysed_config.db_file)

