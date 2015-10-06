require 'rspec'
require './spec/helper'
require 'yaml'
require 'pp'

describe Analyst do
  context 'when add valid hash' do
    it do
      expect(Analyst.new(valid_hash).analyse).to be_truthy
    end

    context 'when required file not exist' do
      it do
        expect { Analyst.new(invalid_file_hash).analyse }.to raise_error(Analyst::RequiredFileNotExist)
      end
    end
  end


  context 'when pass invalid hash' do
    it do
      expect { Analyst.new(invalid_hash).analyse }.to raise_error(Analyst::NotHasRequired)
    end
  end
end

def invalid_hash
  valid = valid_hash
  valid['database'].delete('directory')
  valid
end

def invalid_file_hash
  valid = valid_hash
  valid['template']['form'] = 'not_exist.html'
  valid
end

def valid_hash
  YAML.load <<-EOS
database:
  name: テストフォーム
  key: test_form
  directory: db
template:
  directory: html
  form: form.html
  thank: thank.html
  reply_mail: mail.html
  admin_mail: admin.html
form:
  input:
    - type: text
      key: full_name
      validation:
        - type: required
        - type: length
          value: 1..20
  EOS
end