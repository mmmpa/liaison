class PostToken
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :for_cookie, :for_html, :token_store

  class << self
    def collate(from_cookie, from_html)
      return false if chipped?(from_cookie, from_html)
      return false unless File.exist?(file_name(from_cookie))

      File.read(file_name(from_cookie)) == from_html
    end

    def chipped?(from_cookie, from_html)
      from_cookie.blank? || from_html.blank?
    end

    def file_name(from_cookie)
      (@token_store + from_cookie).to_s
    end

    def ready(token_store)
      @token_store = token_store
      FileUtils.mkdir_p(@token_store)
    end

    def sweep(from_cookie)
      File.delete(file_name(from_cookie))
    rescue
      nil
    end

    def create!
      token = new(@token_store)
      token.save!
      token
    end
  end

  def initialize(token_store)
    super()
    self.token_store = token_store

    begin
      self.for_cookie = SecureRandom.hex(32)
      self.for_html = SecureRandom.hex(32)
    end while invalid?
  end

  def invalid?
    File.exist?(file_name)
  end

  def file_name
    (token_store + for_cookie).to_s
  end

  def save!
    File.write(file_name, for_html)
  end

  class TokenMissing < StandardError
  end
end
