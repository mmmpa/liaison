Dir[Pathname.new("#{__dir__}") + './**/*.rb'].each { |f| require f }

class Liaison
  NO_INPUT = :no_input
  NOT_VALIDATED = :not_validated
  VALIDATED = :validated
  VERIFIED = :verified

  attr_accessor :state

  class << self
    def ready(configure)

    end
  end

  def initialize(configuration, src_root, input)
    @configuration = Analyst.new(src_root, configuration).analyse.configuration
    @method = input[:method].downcase.to_sym
    @tokens = {
      from_cookie: input.delete(:cookie_token),
      from_html: (input[:parameters] || {}).delete('token')
    }
    @parameters = pick_required(input[:parameters] || {})

    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: 'test_db'
    )

    Inquiry.ready(@configuration)
    Inquiry.inject(@configuration)
    PostToken.ready
    FormRenderer.ready(@configuration)

    detect_state!
    lead!
  end

  def raw_parameters
    @raw_input || {}
  end

  def pick_required(params)
    (@configuration.parameters + @configuration.confirmers).inject({}) do |a, attribute_name|
      value = (params[attribute_name.to_s] || params[attribute_name.to_sym])
      if value.is_a?(Array) && value.size == 1
        value = value.first
      end
      a.update(attribute_name.to_sym => value)
    end
  end

  def with_get?
    @method != :post
  end

  def with_post?
    @method == :post
  end

  def detect_state!
    #メソッドの検査
    if with_get?
      no_input!
      return
    end

    #入力内容の検査
    @inquiry = Inquiry.new(@parameters)
    if @inquiry.invalid?
      not_validated!
      return
    end

    #トークンの検査
    if valid_token?
      verified!
      return
    end


    validated!
  end

  def lead!
    case
      when not_validated?
        go(ProcessName::REVISE)
      when validated?
        go(ProcessName::VERIFY)
      when verified?
        go(ProcessName::COMPLETE)
      when no_input?
        go(ProcessName::INPUT)
      else
        go(ProcessName::INPUT)
    end
  end

  def go(process_name)
    case process_name
      when ProcessName::INPUT
        #入力画面表示
        @inquiry = Inquiry.new
      when ProcessName::REVISE
        #修正画面表示
      when ProcessName::VERIFY
        token = PostToken.create!
        #HTML用にトークンをセット
        @inquiry.token = token.for_html
        #クッキーにトークンをセット
        @cookie = feed_cookie(token.for_cookie)
      #確認画面表示
      when ProcessName::COMPLETE
        #メールを送信
        #データベースに登録
        begin
          @inquiry.save!
          sweep!
        rescue
          go(:revise)
        end
      #終了画面表示
      else
        # 中断
        return
    end

    FormRenderer.render(process_name, @inquiry, @cookie)
  end

  def feed_cookie(token)
    CGI::Cookie.new({
                      'name' => :token,
                      'value' => token
                    })
  end

  def sweep!
    PostToken.sweep(@tokens[:from_cookie])
    @inquiry = nil
  end

  def valid_token?
    #paramに含まれるトークンとクッキーのトークンの組み合わせを調べる
    Logger.add([@tokens[:from_cookie], @tokens[:from_html]])

    PostToken.collate(@tokens[:from_cookie], @tokens[:from_html])
  end

  def no_input!
    self.state = NO_INPUT
  end

  def not_validated!
    self.state = NOT_VALIDATED
  end

  def validated!
    self.state = VALIDATED
  end

  def verified!
    self.state = VERIFIED
  end

  def no_input?
    state == :no_input
  end

  def not_validated?
    state == :not_validated
  end

  def validated?
    state == :validated
  end

  def verified?
    state == :verified
  end
end