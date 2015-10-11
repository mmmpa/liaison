require 'securerandom'

def valid_params
  {
    full_name: 'full_name',
    gender: 'male',
    hobby: ['Programming', 'PC'],
    mail_address: 'mmmpa.mmmpa+customer@gmail.com',
    mail_address_confirmation: 'mmmpa.mmmpa+customer@gmail.com',
    password: 'a' * 8,
    password_confirmation: 'a' * 8
  }
end

def invalid_params
  {
    full_name: 'full_name',
    gender: 'male',
    hobby: ['Programming'],
    mail_address: 'mmmpa.mmmpa@gmail.com',
    mail_address_confirmation: 'mmmpa@gmail.com',
    password: 'a' * 8,
    password_confirmation: 'a' * 10
  }
end

def invalid_hash
  valid = valid_hash
  valid['store'].delete('token')
  valid
end

def invalid_file_hash
  valid = valid_hash
  valid['template']['form'] = 'not_exist.html'
  valid
end

def valid_hash
  YAML.load <<-EOS
mail:
  from: mmmpa.mmmpa@gmail.com
  admin: mmmpa.mmmpa@gmail.com
  mail_attribute: mail_address
  subject: テストフォーム確認メール
  admin_subject: テストフォーム受信
store:
  token: token
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
          message: 姓名を入力してください
        - type: length
          value:
            min: 2
            max: 20
          message: 2～20文字で入力してください
    - type: text
      key: gender
      item:
        - female
        - male
        - other
      validation:
        - type: required
          message: いずれかを選択してください
        - type: select_one
          message: 正しくない入力が含まれています
    - type: text
      key: hobby
      item:
        - PC
        - Programming
        - Game
      validation:
        - type: select_any
          message: 正しくない入力が含まれています
    - type: text
      key: mail_address
      validation:
        - type: email
          message: メールアドレスの書式が正しくありません
        - type: confirmation
          message: メールアドレスが一致しません
    - type: text
      key: password
      validation:
        - type: confirmation
        - type: length
          value:
            min: 8
            max: 64
          message: 8～64文字で入力してください
        - type: only
          value:
            - string
            - number
          message: 英数字のみ入力可能です
  EOS
end