require 'pathname'
require 'pp'
Dir[Pathname.new("#{__dir__}") + '../app/lib/**/*.rb'].each { |f| require f }
Dir[Pathname.new("#{__dir__}") + './supports/**/*.rb'].each { |f| require f }
