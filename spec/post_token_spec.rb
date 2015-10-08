require 'rspec'
require './spec/helper'

describe Inquiry do
  before :each do
    PostToken.ready
  end

  context 'when new' do
    let(:token) { PostToken.new }

    it { expect(token.for_cookie.size).to eq(64) }
    it { expect(token.for_html.size).to eq(64) }
    it { expect(token.valid?).to be_truthy }
    it { expect(token.save!).to be_truthy }
  end

  context 'after saved' do
    let(:saved) do
      PostToken.new.save!
      PostToken.last
    end

    it { expect(saved.for_cookie.size).to eq(64) }
    it { expect(saved.for_html.size).to eq(64) }
  end

  describe 'token collating' do
    let(:saved) do
      PostToken.new.save!
      PostToken.last
    end

    context 'invalid token' do
      it { expect(PostToken.collate('a', 'b')).to be_falsey }
    end

    context 'valid tokens' do
      it { expect(PostToken.collate(saved.for_cookie, saved.for_html)).to be_truthy }
    end

    context 'valid token and invalid token' do
      it { expect(PostToken.collate(saved.for_cookie, 'a')).to be_falsey }
      it { expect(PostToken.collate('a', saved.for_html)).to be_falsey }
    end
  end

  describe 'token sweeping' do
    let(:saved) do
      PostToken.new.save!
      PostToken.last
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
