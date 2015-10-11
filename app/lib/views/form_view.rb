class FormView
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

  def error(attribute_name, css_class_name = nil)
    return '' unless revise?
    return '' unless (errors = @model.errors.messages[attribute_name.to_sym])

    messages = errors.map do |message|
      %{<li class="error-text">#{message}</li>}
    end.join
    %{<ul class="message-list">#{messages}</ul>}
  end

  def for_verify(attribute_name, css_class_name = nil, multiple = false)
    css_class = gen_css_class(css_class_name)
    inputted = @model.send(attribute_name)
    suffix = multiple ? '[]' : ''
    if inputted.is_a?(Array)
      hidden = inputted.map { |value|
        %{<input type="hidden" name="#{attribute_name}#{suffix}" value="#{disinfect value}">}
      }.join
      %{<div#{css_class}>#{disinfect inputted.join('、')}</div>#{hidden}}
    else
      %{<div#{css_class}>#{disinfect inputted}</div><input type="hidden" name="#{attribute_name}#{suffix}" value="#{disinfect inputted}">}
    end
  end

  def text(attribute_name, css_class_name = nil)
    return for_verify(attribute_name, css_class_name) if verify?

    css_class = gen_css_class(css_class_name)
    inputted = @model.send(attribute_name)
    %{<input type="text" name="#{attribute_name}" value="#{disinfect inputted}"#{css_class}>}
  end

  def radio(attribute_name, css_class_name = nil)
    return for_verify(attribute_name, css_class_name) if verify?
    return '' unless (items = @input[attribute_name.to_sym])

    css_class = gen_css_class(css_class_name)
    selected = @model.send(attribute_name)
    items.map { |value|
      checked = selected == value ? ' checked' : ''
      %{<label><span class="input"><input type="radio" name="#{attribute_name}" value="#{value}"#{css_class}#{checked}></span><span class="label">#{value}</span></label>}
    }.join
  end

  def select(attribute_name, css_class_name = nil)
    return for_verify(attribute_name, css_class_name) if verify?
    return '' unless (items = @input[attribute_name.to_sym])

    css_class = gen_css_class(css_class_name)
    selected = @model.send(attribute_name)
    options = items.map { |value|
      checked = selected == value ? ' selected' : ''
      %{<option value="#{value}"#{checked}>#{value}</option>}
    }.join
    %{<select#{css_class}>#{options}</select>}
  end

  def checkbox(attribute_name, css_class_name = nil)
    return for_verify(attribute_name, css_class_name, true) if verify?
    return '' unless (items = @input[attribute_name.to_sym])

    css_class = gen_css_class(css_class_name)
    selected = @model.send(attribute_name) || []
    items.map { |value|
      checked = selected.include?(value) ? ' checked' : ''
      %{<label><span class="input"><input type="checkbox" name="#{attribute_name}[]" value="#{value}"#{css_class}#{checked}></span><span class="label">#{value}</span></label>}
    }.join
  end

  def gen_css_class(css_class_name = nil)
    css_class_name ? %{ class="#{css_class_name}"} : ''
  end

  def render
    write_html
  end

  def input?
    @mode == UserProcess::INPUT
  end

  def revise?
    @mode == UserProcess::REVISE
  end

  def verify?
    @mode == UserProcess::VERIFY
  end

  def complete?
    @mode == UserProcess::COMPLETE
  end

  private

  def disinfect(string)
    CGI.escapeHTML(string.to_s)
  end

  def detect_status
    "OK"
  end

  def write_html
    @stored_html ||=
      case @mode
        when UserProcess::INPUT, UserProcess::REVISE, UserProcess::VERIFY
          ERB.new(File.read(@template[:form])).result(binding)
        when UserProcess::COMPLETE
          ERB.new(File.read(@template[:thank])).result(binding)
        else
          # 中断
          return
      end
  end
end