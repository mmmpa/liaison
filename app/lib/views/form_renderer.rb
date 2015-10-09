class FormRenderer
  class << self
    def render(*args)
      new(@template, @input, *args).render
    end

    def ready(config)
      @template = config.template
      @input = config.input
    end
  end

  def initialize(template, input, mode, model = nil, cookie = nil)
    @template = template
    @input = input
    @mode = mode
    @model = model
    @cookie = cookie
  end

  def token
    %{<input type="hidden" name="token" value="#{disinfect @model.token}">} if @model.token
  end

  def text(attribute_name, html_class = nil)
    html = html_class ? %{ class="#{html_class}"} : ''
    inputed = @model.send(attribute_name)
    %{<input type="text" name="#{attribute_name}" value="#{disinfect inputed}"#{html}>}

  end

  def radio(attribute_name, html_class = nil)
    return '' unless (items = @input[attribute_name.to_sym])

    html = html_class ? %{ class="#{html_class}"} : ''
    selected = @model.send(attribute_name)
    items.map { |value|
      checked = selected == value ? ' checked' : ''
      %{<label><span class="input"><input type="radio" name="#{attribute_name}" value="#{value}"#{html}#{checked}></span><span class="label">#{value}</span></label>}
    }.join
  end

  def select(attribute_name, html_class = nil)
    return '' unless (items = @input[attribute_name.to_sym])

    html = html_class ? %{ class="#{html_class}"} : ''
    selected = @model.send(attribute_name)
    options = items.map { |value|
      checked = selected == value ? ' selected' : ''
      %{<option value="#{value}"#{checked}>#{value}</option>}
    }.join
    %{<selected#{html}>#{options}</select>}
  end

  def checkbox(attribute_name, html_class = nil)
    return '' unless (items = @input[attribute_name.to_sym])

    html = html_class ? %{ class="#{html_class}"} : ''
    selected = @model.send(attribute_name)
    items.map { |value|
      checked = selected.include?(value) ? ' checked' : ''
      %{<label><span class="input"><input type="checkbox" name="#{attribute_name}" value="#{value}"#{html}#{checked}></span><span class="label">#{value}</span></label>}
    }.join
  end

  def render
    CGI.new.out({
                  'status' => detect_status,
                  'connection' => 'close',
                  'type' => 'text/html',
                  'charaset' => 'utf-8',
                  'language' => 'ja',
                  'cookie' => [@cookie]
                }) {
      write_html + Logger.log
    }
  end

  private

  def disinfect(string)
    CGI.escapeHTML(string.to_s)
  end

  def detect_status
    "OK"
  end

  def write_html
    case @mode
      when ProcessName::INPUT, ProcessName::REVISE, ProcessName::VERIFY
        ERB.new(File.read(@template[:form])).result(binding)
      when ProcessName::COMPLETE
        ERB.new(File.read(@template[:thank])).result(binding)
      else
        # 中断
        return
    end
  end
end