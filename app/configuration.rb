require 'pathname'
require 'yaml'
require 'pp'
require 'cgi'
Dir["#{__dir__}/lib/**/*.rb"].each { |f| require f }

def execute
  print "Content-Type:text/html;charset=UTF8\n\n"

  data = YAML.load_file("#{__dir__}/configuration/configuration.yaml")
  Analyst.new(data)
  print data.to_s
end
