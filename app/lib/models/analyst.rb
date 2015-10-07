require 'pathname'

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
    self || (raise NotYetAnalysed)
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
    @validators = {}

    @configuration['form']['input'].each do |input|
      key = input['key']
      validators = {}

      if (validations = input['validation']).is_a?(Array)
        validations.map { |validation|
          detect_validator(key, validation)
        }.each { |validator|
          validators.merge!(validator)
        }
      end

      if validators[:confirmation_target]
        confirmation_target = validators.delete(:confirmation_target)
        @parameters.push(confirmation_target)
      end

      @validators.merge!(key => validators)
      @parameters.push(key)
    end
  end

  def message_or_boolean(message)
    message ? {message: message} : true
  end

  def detect_validator(key, validation)
    validators = {}
    case validation['type'].to_sym
      when :required
        validators.merge!(presence: message_or_boolean(validation['message']))
      when :confirmation
        confirmation_key = key + '_confirmation'
        validators.merge!(confirmation: message_or_boolean(validation['message']))
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
                            in: validation['value'],
                            allow_blank: true
                          })
      when :select_any
        validators.merge!(inclusion: {
                            message: validation['message'],
                            in: validation['value'],
                            allow_blank: true})
      else
        nil
    end

    validators
  end

  def file_exist?
    [
      @configuration['database']['directory'],
      @configuration['template']['form'],
      @configuration['template']['thank'],
      @configuration['template']['reply_mail'],
      @configuration['template']['admin_mail'],
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
