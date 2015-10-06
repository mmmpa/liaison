
require 'pathname'
Dir[Pathname.new("#{__dir__}") + '../app/lib/**/*.rb'].each { |f| require f }
