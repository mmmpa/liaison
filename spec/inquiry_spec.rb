require 'rspec'
require './spec/helper'

describe Inquiry do
  let(:analysed_config) { Analyst.new('spec/fixtures', valid_hash).analyse.config }

  before :each do
    Inquiry.ready(analysed_config)
    PostToken.ready(analysed_config.token_store)
    FormView.ready(analysed_config)
  end

  context 'with database' do
    it do
      Inquiry.new
    end
  end

  describe 'dynamic validator injection' do
    context 'with invalid params' do
      context 'when validate' do
        it do
          expect(Inquiry.new.valid?).to be_falsey
        end
      end

      describe 'validator' do
        let(:model) { Inquiry.new }

        context 'with confirmation' do
          it do
            model.mail_address = 'a@a.com'
            model.mail_address_confirmation = 'a2@a.com'
            model.valid?
            expect(model.errors[:mail_address_confirmation]).to include('メールアドレスが一致しません')
          end
        end

        context 'with email' do
          it do
            model.mail_address = 'a@@a.com'
            model.valid?
            expect(model.errors[:mail_address]).to include('メールアドレスの書式が正しくありません')
          end

          it do
            model.mail_address = '@a.com'
            model.valid?
            expect(model.errors[:mail_address]).to include('メールアドレスの書式が正しくありません')
          end

          it do
            model.mail_address = 'aa.com'
            model.valid?
            expect(model.errors[:mail_address]).to include('メールアドレスの書式が正しくありません')
          end

          it do
            model.mail_address = 'a@a..com'
            model.valid?
            expect(model.errors[:mail_address]).to include('メールアドレスの書式が正しくありません')
          end

          it do
            model.mail_address = 'a@a.com'
            model.valid?
            expect(model.errors[:mail_address]).not_to include('メールアドレスの書式が正しくありません')
          end
        end

        context 'with length' do
          it do
            model.full_name = 'あ'
            model.valid?
            expect(model.errors[:full_name]).to include('2～20文字で入力してください')
          end

          it do
            model.full_name = 'あ' * 21
            model.valid?
            expect(model.errors[:full_name]).to include('2～20文字で入力してください')
          end

          it do
            model.full_name = 'あ' * 2
            model.valid?
            expect(model.errors[:full_name]).not_to include('2～20文字で入力してください')
          end
        end

        context 'with presence' do
          it do
            model.valid?
            expect(model.errors[:full_name]).to include('姓名を入力してください')
          end

          it do
            model.full_name = ''
            model.valid?
            expect(model.errors[:full_name]).to include('姓名を入力してください')
          end

          it do
            model.full_name = 'あ'
            model.valid?
            expect(model.errors[:full_name]).not_to include('姓名を入力してください')
          end
        end

        context 'with select any' do
          it do
            model.valid?
            expect(model.errors[:hobby]).to match_array([])
          end

          it do
            model.hobby = %w(PC Programming)
            model.valid?
            expect(model.errors[:hobby]).to match_array([])
          end

          it do
            model.hobby = %w(PC Reading)
            model.valid?
            expect(model.errors[:hobby]).to include('正しくない入力が含まれています')
          end
        end

        context 'with select one' do
          it do
            model.valid?
            expect(model.errors[:gender]).to include('いずれかを選択してください')
          end

          it do
            model.gender = ''
            model.valid?
            expect(model.errors[:gender]).to include('いずれかを選択してください')
          end

          it do
            model.gender = 'man'
            model.valid?
            expect(model.errors[:gender]).not_to include('いずれかを選択してください')
          end

          it do
            model.gender = 'man'
            model.valid?
            expect(model.errors[:gender]).to include('正しくない入力が含まれています')
          end

          it do
            model.gender = 'male'
            model.valid?
            expect(model.errors[:gender]).not_to include('正しくない入力が含まれています')
          end

          it do
            model.gender = 'male, female'
            model.valid?
            expect(model.errors[:gender]).to include('正しくない入力が含まれています')
          end
        end
      end
    end

    context 'with valid params' do
      context 'when validate' do
        it do
          expect(Inquiry.new(**valid_params).valid?).to be_truthy
        end
      end
    end
  end
end
