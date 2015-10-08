class Analyst
  def initialize(root, configuration)
    @root = root
    @configuration = configuration
  end

  def analyse
    has_required_value?
    file_exist?
    pick_up_database!
    pick_up_parameters!
    @result = @configuration

    self
  end

  def configuration
    raise NotYetAnalysed unless @database
    self
  end

  def template
    @template || (raise NotYetAnalysed)
  end

  def input
    @input || (raise NotYetAnalysed)
  end

  def result
    @result || (raise NotYetAnalysed)
  end

  def database
    @database || (raise NotYetAnalysed)
  end

  def parameters
    @parameters || (raise NotYetAnalysed)
  end

  def validators
    @validators || (raise NotYetAnalysed)
  end

  def confirmers
    @confirmers || (raise NotYetAnalysed)
  end

  private

  def pick_up_database!
    @database = {
      table_name: @configuration['database']['key'],
      columns: @configuration['form']['input'].inject({}) { |hash, input|
        hash.merge!(
          (input['key'] || (raise DBParameterMissing)) => (input['type'] || (raise DBParameterMissing))
        )
      }
    }
  end

  def pick_up_parameters!
    @parameters = []
    @confirmers = []
    @validators = {}
    @input = {}

    @configuration['form']['input'].each do |input|
      key = input['key']
      validators = {}

      if (validations = input['validation']).is_a?(Array)
        validations.map { |validation|
          detect_validator(input, key, validation)
        }.each { |validator|
          validators.merge!(validator)
        }
      end

      if validators[:confirmation_target]
        confirmation_target = validators.delete(:confirmation_target)
        @confirmers.push(confirmation_target)
        #@validators.merge!(confirmation_target => {presence: true})
      end

      @validators.merge!(key => validators)
      @parameters.push(key)
    end
  end

  def message_or_boolean(message)
    message ? {message: message} : true
  end

  def detect_validator(input, key, validation)
    validators = {}
    case validation['type'].to_sym
      when :required
        validators.merge!(presence: message_or_boolean(validation['message']))
      when :confirmation
        confirmation_key = key + '_confirmation'
        validators.merge!(confirmation: {message: validation['message']})
        validators.merge!(confirmation_target: confirmation_key)
      when :length
        validators.merge!(length: {
                            message: validation['message'],
                            minimum: validation['value']['min'] || 0,
                            maximum: validation['value']['max'] || 1000,
                            allow_blank: true
                          })
      when :select_one
        validators.merge!(inclusion: {
                            message: validation['message'],
                            in: input['item'],
                            allow_blank: true
                          })
      when :select_any
        validators.merge!(select_any: {
                            message: validation['message'],
                            in: input['item'],
                          })
      else
        nil
    end

    validators
  end

  def file_exist?
    @template = {}

    %w(form thank reply_mail admin_mail).each do |name|
      path = Pathname.new(File.expand_path @root) + @configuration['template'][name]
      raise RequiredFileNotExist unless File.exist?(path)
      @template.merge!(name.to_sym => path)
    end

    [
      @configuration['database']['directory'],
    ].each do |name|
      raise RequiredFileNotExist unless File.exist?(Pathname.new(@root) + name)
    end
  end

  def has_required_value?
    trace(@configuration, required_key_value)
  end

  def trace(required, req)
    req.each_pair do |key, values|
      raise NotHasRequired unless required[key.to_s].is_a?(Hash)

      values.each do |value|
        raise NotHasRequired unless required[key.to_s][value.to_s]
      end
    end
  end

  def required_key_value
    {
      database: [:key, :directory],
      template: [:form, :thank, :reply_mail, :admin_mail],
      form: [:input]
    }
  end

  class DBParameterMissing < StandardError
  end
  class NotYetAnalysed < StandardError
  end
  class NotHasRequired < StandardError
  end
  class RequiredFileNotExist < StandardError
  end
end
