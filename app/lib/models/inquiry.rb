require 'active_record'

class Inquiry < ActiveRecord::Base
  class << self
    def ready(configure)
      return if @initialized

      ActiveRecord::Base.establish_connection(
        adapter: 'sqlite3',
        database: 'db'
      )

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

      Inquiry.class_eval do
        configure.parameters.each do |name|
          if (validator = configure.validators[name]) && validator != {}
            validates(name, **validator)
          end
        end
        attr_accessor *configure.parameters
      end

      @initialized = true
    end
  end
end

