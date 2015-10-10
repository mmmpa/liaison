class Inquiry < ActiveRecord::Base
  include DynamicInjector

  class << self
    def ready(configure)
      return if @initialized

      self.table_name =  configure.db_table

      inject_validators(configure.validators)
      inject_attributes(:token)

      @initialized = true
    end
  end
end

