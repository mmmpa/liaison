require 'active_record'

class InquiryTable < ActiveRecord::Migration
  class << self
    attr_reader :table_name, :columns

    def create(table_name)
      @table_name = table_name
      migrate(:up)
    end

    def change(table_name, columns)
      p :change
      @table_name = table_name
      @columns = columns
      migrate(:change)
    end
  end

  def change
    begin
      create_table self.class.table_name { |t|}
    rescue
      nil
    end

    if self.class.columns
      self.class.columns.each_pair do |key, value|
        begin
          add_column(self.class.table_name, key, value)
        rescue
          nil
        end
      end
    end
  end
end