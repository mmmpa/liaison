class FormRenderer
  class << self
    def render(*args)
      new(@template, *args).render
    end

    def ready(configuration)
      @template = configuration.template
    end
  end

  def initialize(template, mode, model = nil, cookie = nil)
    @template = template
    @mode = mode
    @model = model
    @cookie = cookie
  end

  def token
    %{<input type="hidden" name="token" value="#{disinfect(@model.token)}">} if @model.token
  end

  def render
    CGI.new.out({
                  'status' => detect_status,
                  'connection' => 'close',
                  'type' => 'text/html',
                  'charaset' => 'utf-8',
                  'language' => 'ja',
                  'cookie' => @coolie
                }) {
      write_html
    }
  end

  private

  def disinfect(string)
    CGI.escapeHTML(string)
  end

  def detect_status
    "OK"
  end

  def write_html
    case @mode
      when ProcessName::INPUT
        #入力画面表示
        ERB.new(File.read(@template[:form])).result(binding)
      when ProcessName::REVISE
        #修正画面表示
        ERB.new(File.read(@template[:form])).result(binding)
      when ProcessName::VERIFY
        #確認画面表示
        ERB.new(File.read(@template[:form])).result(binding)
      when ProcessName::COMPLETE
        #終了画面表示
        ERB.new(File.read(@template[:thank])).result(binding)
      else
        # 中断
        return
    end
  end
end