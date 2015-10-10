require 'pathname'
require 'yaml'
require 'pp'
require 'cgi'
require 'erb'
require 'active_record'
require 'active_support'

Dir["#{__dir__}/lib/**/*.rb"].each(&method(:require))

class LiaisonApplication
  class << self
    def execute
      Logger.work!
      Liaison.new(config, root_path + '../spec/fixtures', InputDealer.(CGI.new))
    rescue => e
      print "Content-type: text/html\n\n"
      print e
    end

    def config
      YAML.load_file(root_path + 'configuration/configuration.yaml')
    end

    def root_path
      Pathname.new(File.expand_path(__dir__))
    end
  end
end

