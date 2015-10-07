require 'rspec'
require './spec/helper'

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

    context 'when get configuration' do
      context 'before analysing' do
        it do
          expect { Analyst.new('spec/fixtures', valid_hash).configuration }.to raise_error(Analyst::NotYetAnalysed)
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