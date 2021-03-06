require 'rspec'
require './spec/helper'

describe PostToken do
  let(:config) { Analyst.new('spec/fixtures', valid_hash).analyse.config }

  before :each do
    PostToken.ready(config.token_store)
  end

  describe 'token creation' do
    context 'when new' do
      let(:token) { PostToken.new(config.token_store) }

      it { expect(token.for_cookie.size).to eq(64) }
      it { expect(token.for_html.size).to eq(64) }
      it { expect(token.valid?).to be_truthy }
      it { expect(token.save!).to be_truthy }
      it { expect(PostToken.create!).to be_a(PostToken) }
    end

    context 'after saved' do
      let(:saved) do
        PostToken.create!
      end

      it { expect(saved.for_cookie.size).to eq(64) }
      it { expect(saved.for_html.size).to eq(64) }
    end
  end

  describe 'token collating' do
    let(:saved) do
      PostToken.create!
    end

    context 'with blank' do
      it { expect(PostToken.collate(nil, saved.for_html)).to be_falsey }
      it { expect(PostToken.collate('', saved.for_html)).to be_falsey }
      it { expect(PostToken.collate(saved.for_cookie, nil)).to be_falsey }
      it { expect(PostToken.collate(saved.for_cookie, '')).to be_falsey }
    end

    context 'with invalid token' do
      it { expect(PostToken.collate('a', 'b')).to be_falsey }
    end

    context 'with valid tokens' do
      it { expect(PostToken.collate(saved.for_cookie, saved.for_html)).to be_truthy }
    end

    context 'with valid token and invalid token' do
      it { expect(PostToken.collate(saved.for_cookie, 'a')).to be_falsey }
      it { expect(PostToken.collate('a', saved.for_html)).to be_falsey }
    end
  end

  describe 'token sweeping' do
    let(:saved) do
      PostToken.create!
    end

    context 'after swept' do
      it do
        expect(PostToken.collate(saved.for_cookie, saved.for_html)).to be_truthy
        PostToken.sweep(saved.for_cookie)
        expect(PostToken.collate(saved.for_cookie, saved.for_html)).to be_falsey
      end
    end
  end
end
