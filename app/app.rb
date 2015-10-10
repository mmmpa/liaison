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

      ready

      Liaison.new(analysed_config).execute(InputDealer.(CGI.new))
    rescue => e
      print "Content-type: text/html\n\n"
      print e
    ensure
      close
    end

    def ready
      DatabaseMan.open(analysed_config.db_file)
      Inquiry.ready(analysed_config)
      Inquiry.inject(analysed_config)
      PostToken.ready
      FormRenderer.ready(analysed_config)
    end

    def close
      DatabaseMan.close
    end

    def analysed_config
      @stored_analysed_config ||= Analyst.new(src_root_path, config).analyse.config
    end

    def config
      @stored_config ||= YAML.load_file(root_path + 'configuration/configuration.yaml')
    end

    def root_path
      Pathname.new(File.expand_path(__dir__))
    end

    def src_root_path
      root_path
    end
  end
end

