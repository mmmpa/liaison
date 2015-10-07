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
    let(:config) { Analyst.new('spec/fixtures', valid_hash).analyse.configuration }

    before :each do
      Inquiry.ready(config)
      Inquiry.inject(config)
    end

    context 'with invalid params' do
      context 'when validate' do
        it do
          expect(Inquiry.new.valid?).to be_falsey
        end
      end

      context 'when save' do
        it do
          expect{Inquiry.new.save!}.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    context 'with valid params' do
      context 'when validate' do
        it do
          expect(Inquiry.new(**valid_params).valid?).to be_truthy
        end
      end

      context 'when save' do
        it do
          expect(Inquiry.new(**valid_params).save!).to be_truthy
          p Inquiry.last

        end
      end
    end
  end
end
