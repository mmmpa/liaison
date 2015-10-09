require 'rspec'
require './spec/helper'

describe Liaison do
  let(:config) { Analyst.new('spec/fixtures', valid_hash).analyse.config }

  before :each do
    DatabaseMan.open(config.db_file)
  end

  describe 'state detecting' do
    context 'with get method' do
      context 'with no parameter' do
        it do
          liaison = Liaison.new(valid_hash, 'spec/fixtures', {method: :get, parameters: {}})
          expect(liaison.no_input?).to be_truthy
        end
      end

      context 'with valid parameter' do
        it do
          liaison = Liaison.new(valid_hash, 'spec/fixtures', {method: :get, parameters: valid_params})
          expect(liaison.no_input?).to be_truthy
        end
      end

      context 'with invalid parameter' do
        it do
          liaison = Liaison.new(valid_hash, 'spec/fixtures', {method: :get, parameters: valid_params})
          expect(liaison.no_input?).to be_truthy
        end
      end
    end

    context 'with post method' do
      context 'with no parameter' do
        it do
          liaison = Liaison.new(valid_hash, 'spec/fixtures', {method: :post, parameters: {}})
          expect(liaison.not_validated?).to be_truthy
        end
      end

      context 'with valid parameter' do
        context 'with no token' do
          it do
            liaison = Liaison.new(valid_hash, 'spec/fixtures', {method: :post, parameters: valid_params})
            expect(liaison.validated?).to be_truthy
          end
        end

        context 'with valid token' do
          it do
            token = PostToken.create!
            liaison = Liaison.new(valid_hash, 'spec/fixtures', {method: :post, parameters: valid_params.merge!(token: token.for_html), cookie_token: token.for_cookie})
            expect(liaison.verified?).to be_truthy
          end
        end

        context 'with valid token post again' do
          it do
            token = PostToken.create!
            Liaison.new(valid_hash, 'spec/fixtures', {method: :post, parameters: valid_params.merge!(token: token.for_html), cookie_token: token.for_cookie})
            liaison = Liaison.new(valid_hash, 'spec/fixtures', {method: :post, parameters: valid_params.merge!(token: token.for_html), cookie_token: token.for_cookie})
            expect(liaison.verified?).to be_falsey
          end
        end

        context 'with invalid cookie token' do
          it do
            token = PostToken.create!
            liaison = Liaison.new(valid_hash, 'spec/fixtures', {method: :post, parameters: valid_params.merge!(token: token.for_html), cookie_token: 'a'})
            expect(liaison.verified?).to be_falsey
          end
        end

        context 'with invalid html token' do
          it do
            token = PostToken.create!
            liaison = Liaison.new(valid_hash, 'spec/fixtures', {method: :post, parameters: valid_params.merge!(token: 'a'), cookie_token: token.for_cookie})
            expect(liaison.verified?).to be_falsey
          end
        end
      end

      context 'with invalid parameter' do
        it do
          liaison = Liaison.new(valid_hash, 'spec/fixtures', {method: :post, parameters: invalid_params})
          expect(liaison.not_validated?).to be_truthy
        end

        context 'with valid token' do
          it do
            token = PostToken.create!
            liaison = Liaison.new(valid_hash, 'spec/fixtures', {method: :post, parameters: invalid_params.merge!(token: token.for_html), cookie_token: token.for_cookie})
            expect(liaison.verified?).to be_falsey
          end
        end
      end
    end
  end

  describe 'inquiry accepting' do
    context 'when posted valid parameter' do
      it do
        token = PostToken.create!
        count = Inquiry.count
        Liaison.new(valid_hash, 'spec/fixtures', {method: :post, parameters: valid_params.merge!(token: token.for_html), cookie_token: token.for_cookie})
        DatabaseMan.open(config.db_file)
        expect(Inquiry.count).to eq(count + 1)
      end
    end
  end
end
