require 'pathname'
require 'yaml'
require 'pp'
require 'cgi'
require 'erb'
require 'active_record'
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
    ensure
      close
    end

    def build_database(analysed_config)
      DatabaseMan.open(analysed_config.db_file)
      table_name = analysed_config.db_table
      table_columns = analysed_config.db_columns

      unless ActiveRecord::Base.connection.table_exists?(table_name)
        InquiryTable.create(table_name)
      end

      InquiryTable.change(table_name, table_columns) if table_columns != {}
      DatabaseMan.close
    end

    def ready
      DatabaseMan.open(analysed_config.db_file)
      Inquiry.ready(analysed_config)
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

