require 'pathname'
require 'yaml'
require 'pp'
require 'cgi'
require 'erb'
Dir["#{__dir__}/lib/**/*.rb"].each { |f| require f }

def execute
  data = YAML.load_file("#{__dir__}/configuration/configuration.yaml")
  Analyst.new('__dir__', data)
end
