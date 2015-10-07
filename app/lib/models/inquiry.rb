require 'active_record'


class InquiryTable < ActiveRecord::Migration
  def up
    create_table :test_table do |t|
      t.string :name
      t.string :label
      t.text :value
      t.string :type
      t.integer :position
    end
  end

  def down
    drop_table :test_table
  end
end

class Inquiry < ActiveRecord::Base
  self.table_name = 'test_table'

  class << self
    def inject(configure)
      inputs = configure['input']
      Inquiry.class_eval {
        parameters = inputs.map do |input|
          key = input['key'].to_sym
          validators = {}
          if (validations = input['validation']).is_a?(Array)
            validations.map do |validation|
              case validation['type'].to_sym
                when :required
                  validators.merge!({presence: true})
                when :length
                  validators.merge!({length: {
                    minimum: validation['value']['min'] || 0,
                    maximum: validation['value']['max'] || 1000
                  }})
                when :select_one
                  validators.merge!({inclusion: validation['value']})
                when :select_any
                  validators.merge!({inclusion: validation['value']})
              end
            end
          end
          validates(key, **validators) if validators != {}

          key
        end
        p parameters
        attr_accessor *parameters.flatten
      }
    end
  end
end

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db'
)
begin
  InquiryTable.migrate(:up)
rescue
end