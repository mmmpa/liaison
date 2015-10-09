require 'pathname'
require 'yaml'
require 'pp'
require 'cgi'
require 'erb'
require 'active_record'
require 'active_support'

Dir["#{__dir__}/lib/**/*.rb"].each { |f| require f }

Logger.work!

def execute
  root_path = Pathname.new(File.expand_path(__dir__))
  config = YAML.load_file(root_path + 'configuration/configuration.yaml')
  Liaison.new(config, root_path + '../spec/fixtures', Coordinator.(CGI.new))
rescue => e
  e.backtrace.each(&->(el){p el})
  p e
end
