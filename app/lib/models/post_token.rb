require 'active_record'

class PostToken < ActiveRecord::Base
  validates :for_cookie, :for_html, presence: true
  validates :for_cookie, uniqueness: {with: :for_html}

  class << self
    def collate(from_cookie, from_html)
      return false if is_blank?(from_cookie, from_html)
      where(for_cookie: from_cookie).where(for_html: from_html).size > 0
    end

    def is_blank?(from_cookie, from_html)
      !from_cookie || from_cookie == '' || !from_html || from_html == ''
    end

    def ready
      unless ActiveRecord::Base.connection.table_exists?(:secret_token_table)
        TokenTable.migrate(:up)
      end

      self.table_name = 'secret_token_table'
    end

    def sweep(from_cookie)
      where(for_cookie: from_cookie).delete_all
    end

    def create!
      token = new
      token.save!
      token
    end
  end

  def initialize
    super

    begin
      self.for_cookie = SecureRandom.hex(32)
      self.for_html = SecureRandom.hex(32)
    end while invalid?
  end

  class TokenMissing < StandardError
  end
end
