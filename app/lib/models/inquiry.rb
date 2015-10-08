require 'active_record'
require "#{__dir__}/ar_configuration_injector"

class Inquiry < ActiveRecord::Base
  include ARConfigurationInjector

  class << self
    def ready(configure)
      return if @initialized

      table_name = configure.database[:table_name]
      table_columns = configure.database[:columns]

      ready_table(table_name)
      ready_column(table_name, table_columns)
    end

    def ready_table(table_name)
      unless ActiveRecord::Base.connection.table_exists?(table_name)
        InquiryTable.create(table_name)
      end

      self.table_name = table_name
    end

    def ready_column(table_name, table_columns)
      self.columns.each do |column_information|
        table_columns.delete(column_information.name)
      end

      InquiryTable.change(table_name, table_columns) if table_columns != {}
    end

    def inject(configure)
      return if @initialized

      inject_validators(configure.validators)
      inject_attributes(*configure.parameters)

      @initialized = true
    end
  end
end

