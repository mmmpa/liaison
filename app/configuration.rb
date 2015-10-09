require 'pathname'
require 'yaml'
require 'pp'
require 'cgi'
require 'erb'
require 'active_record'

Dir["#{__dir__}/lib/**/*.rb"].each { |f| require f }

def execute
  root_path = Pathname.new(File.expand_path(__dir__))
  configuration = YAML.load_file(root_path + 'configuration/configuration.yaml')
  cgi = CGI.new
  Liaison.new(configuration, root_path + '../spec/fixtures', {method: cgi.request_method || 'GET', parameters: cgi.params, cookie_token: cgi.cookies['token'] })
rescue => e
  e.backtrace.each(&->(el){p el})
  p e
end

def test
  print "Content-type: text/html\n\n"
end