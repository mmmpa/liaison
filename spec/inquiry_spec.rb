require 'rspec'
require './spec/helper'
require 'yaml'
require 'pp'

describe Inquiry do
  context 'with database' do
    it do
      Inquiry.new
    end
  end

  describe 'dynamic validator injection' do
    before :each do
      Inquiry.inject(valid_hash['form'])
    end

    context 'with invalid params' do
      it do
        expect(Inquiry.new.valid?).to be_falsey
      end
    end

    context 'with valid params' do
      it do
        expect(Inquiry.new(
                 full_name: 'full_name',
                 gender: 'male',
                 hobby: 'Programming',
                 mail_address: 'mmmpa.mmmpa@gmail.com',
                 password: 'a' * 8,
                 password_confirmation: 'a' * 8
               ).valid?).to be_truthy
      end
    end
  end
end
