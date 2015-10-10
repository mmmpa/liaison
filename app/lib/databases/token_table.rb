require 'active_record'

class TokenTable < ActiveRecord::Migration
  def change
    create_table :secret_token_table do |t|
      t.string :for_cookie, null: false
      t.string :for_html, null: false
    end

    add_index :secret_token_table, [:for_cookie, :for_html], unique: true
  end
end