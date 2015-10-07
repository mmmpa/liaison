Dir[Pathname.new("#{__dir__}") + './**/*.rb'].each { |f| require f }

class Liaison
  attr_accessor :state

  class << self
    def ready(configure)

    end
  end

  def initialize(configuration, input)
    @configuration = configuration
    @method = input[:method]
    @parameters = pick_required(input[:parameters])

    detect_state!
    lead!
  end

  def pick_required(params)
    params.slice(*@configuration.parameters)
  end

  def detect_state!
    #メソッドの検査
    if @method == :get || @method != :post
      self.state = :no_input
      return
    end

    #入力内容の検査
    @inquiry = Inquiry.new(@parameters)
    unless @inquiry.valid?
      self.state = :not_validated
      return
    end

    #トークンの検査
    if valid_token?
      self.state = :verified
      return
    end

    self.state = :validated
  end

  def lead!
    case
      when not_validated?
        go(:revise)
      when validate?
        go(:verify)
      when verified?
        go(:complete)
      else
        go(:input)
    end
  end

  def go(view)
    case
      when :input
        #入力画面表示
      when :revise
        #修正画面表示
      when :verify
        #hiddenにトークンをセット
        #クッキーにトークンをセット
        #確認画面表示
      when :complete
        #データベースに登録
        @inquiry.save!
      #終了画面表示
      #メールを送信
      else
        nil
    end
  end

  def valid_token?
    #paramに含まれるトークンとクッキーのトークンの組み合わせを調べる
  end

  def blank?
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