require 'pathname'
require 'yaml'
require 'pp'
require 'cgi'
require 'erb'
require 'active_record'
require 'active_model'
require 'active_model/validations'
require 'active_support'
require 'email_validator'

Dir["#{__dir__}/lib/**/*.rb"].each do |file|
  require(file) unless file.include?('mailer.rb')
end

class LiaisonApplication
  class << self
    def execute
      ready
      Liaison.new(analysed_config).execute(InputDealer.(CGI.new)).try_send_mail
    rescue => e
      print "Content-type: text/html\n\n"
      print e
    end

    def ready
      Inquiry.ready(analysed_config)
      PostToken.ready(analysed_config)
      FormRenderer.ready(analysed_config)
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

