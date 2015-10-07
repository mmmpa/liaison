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
    - type: select_one
      key: gender
      value:
        - female
        - male
        - other
      validation:
        - type: required
    - type: select_any
      key: hobby
      value:
        - PC
        - Programming
        - Game
      validation:
        - type: required
    - type: email
      key: mail_address
      validation:
        - type: email
    - type: password
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