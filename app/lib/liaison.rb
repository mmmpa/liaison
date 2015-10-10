class Liaison
  attr_accessor :state

  def initialize(config)
    @config = config
  end

  def execute(input)
    @method = input[:method]
    @tokens = pick_tokens(input)
    @parameters = pick_required(input)

    detect_state!
    lead!

    self
  end

  def detect_state!
    #メソッドの検査
    if get?
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
        go(UserProcess::REVISE)
      when validated?
        go(UserProcess::VERIFY)
      when verified?
        go(UserProcess::COMPLETE)
      when no_input?
        go(UserProcess::INPUT)
      else
        go(UserProcess::INPUT)
    end
  end

  def go(process_name)
    case process_name
      when UserProcess::INPUT
        @inquiry = Inquiry.new
      when UserProcess::REVISE
      when UserProcess::VERIFY
        token = PostToken.create!
        #トークンのセット
        @inquiry.token = token.for_html
        @cookie = bake_cookie(token.for_cookie)
      when UserProcess::COMPLETE
        #データベースに登録
        begin
          @inquiry.save!
          sweep!
        rescue
          go(:revise)
          return
        end
      else
        return
    end

    FormRenderer.render(process_name, @inquiry, @cookie)

    #画面描画後にメールを送信
    if process_name == UserProcess::COMPLETE && @config.mail != {}
      require "#{__dir__}/mail/mailer.rb"
      Mailer.send_to_user(@config, @inquiry).deliver_now
      Mailer.send_to_admin(@config, @inquiry).deliver_now
    end
  end

  def bake_cookie(token)
    CGI::Cookie.new({'name' => :token, 'value' => token})
  end

  def pick_tokens(input)
    {
      from_cookie: input[:cookie_token],
      from_html: input[:parameters][:token]
    }
  end

  def pick_required(input)
    @config.permitted_parameters.inject({}) do |a, attribute_name|
      a.update(attribute_name => input[:parameters][attribute_name])
    end
  end

  def sweep!
    PostToken.sweep(@tokens[:from_cookie])
  end

  def no_input!
    self.state = LiaisonState::NO_INPUT
  end

  def not_validated!
    self.state = LiaisonState::NOT_VALIDATED
  end

  def validated!
    self.state = LiaisonState::VALIDATED
  end

  def verified!
    self.state = LiaisonState::VERIFIED
  end

  def no_input?
    state == LiaisonState::NO_INPUT
  end

  def not_validated?
    state == LiaisonState::NOT_VALIDATED
  end

  def validated?
    state == LiaisonState::VALIDATED
  end

  def verified?
    state == LiaisonState::VERIFIED
  end

  def valid_token?
    PostToken.collate(@tokens[:from_cookie], @tokens[:from_html])
  end

  def get?
    @method != :post
  end

  def post?
    @method == :post
  end
end