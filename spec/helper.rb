require 'pathname'

Dir[Pathname.new("#{__dir__}") + '../app/configuration.rb'].each { |f| require f }
Dir[Pathname.new("#{__dir__}") + './supports/**/*.rb'].each { |f| require f }


