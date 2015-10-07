require 'rspec'
require './spec/helper'
require 'yaml'
require 'pp'

describe Analyst do
  context 'when add valid hash' do
    it do
      expect(Analyst.new('spec/fixtures', valid_hash).analyse).to be_truthy
    end

    context 'when required file not exist' do
      it do
        expect { Analyst.new('spec/fixtures', invalid_file_hash).analyse }.to raise_error(Analyst::RequiredFileNotExist)
      end
    end

    context 'when get result' do
      context 'before analysing' do
        it do
          expect { Analyst.new('spec/fixtures', valid_hash).result }.to raise_error(Analyst::NotYetAnalysed)
        end
      end

      context 'after analysing' do
        it do
          expect(Analyst.new('spec/fixtures', valid_hash).analyse.result).to eq(valid_hash)
        end
      end
    end
  end


  context 'when pass invalid hash' do
    it do
      expect { Analyst.new('spec/fixtures', invalid_hash).analyse }.to raise_error(Analyst::NotHasRequired)
    end

    context 'when get result before analysing' do
      it do
        expect { Analyst.new('spec/fixtures', invalid_hash).result }.to raise_error(Analyst::NotYetAnalysed)
      end
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
  form: html/form.html
  thank: html/thank.html
  reply_mail: html/mail.html
  admin_mail: html/admin.html
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