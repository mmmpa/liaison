require 'securerandom'

def valid_params
  {
    full_name: 'full_name',
    gender: 'male',
    hobby: 'Programming',
    mail_address: 'mmmpa.mmmpa@gmail.com',
    password: 'a' * 8,
    password_confirmation: 'a' * 8
  }
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
  key: #{SecureRandom.hex(4)}
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
          value:
            min: 1
            max: 20
    - type: text
      key: gender
      validation:
        - type: required
        - type: select_one
          value:
            - female
            - male
            - other
    - type: text
      key: hobby
      validation:
        - type: required
        - type: select_any
          value:
            - PC
            - Programming
            - Game
    - type: text
      key: mail_address
      validation:
        - type: email
    - type: text
      key: password
      validation:
        - type: confirmation
        - type: length
          value: 8..84
        - type: only
          value:
            - string
            - number
  EOS
end