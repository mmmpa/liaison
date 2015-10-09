class Analyst
  def initialize(root, config)
    @root = root
    @config = config.deep_symbolize_keys!
  end

  def analyse
    has_required_value?
    normalize_template_path!
    pick_database_configuration!
    pick_inquiry_configuration!

    @result = @config

    self
  end

  def config
    raise NotYetAnalysed unless @result
    self
  end

  def template
    @template || (raise NotYetAnalysed)
  end

  def input
    @inputs || (raise NotYetAnalysed)
  end

  def result
    @result || (raise NotYetAnalysed)
  end

  def database
    @database || (raise NotYetAnalysed)
  end

  def db_file
    database[:file_name]
  end

  def db_table
    database[:table_name]
  end

  def db_columns
    database[:columns]
  end

  def permitted_parameters
    attributes + additional_attributes
  end

  def attributes
    @attributes || (raise NotYetAnalysed)
  end

  def validators
    @validators || (raise NotYetAnalysed)
  end

  def additional_attributes
    @additional_attributes || (raise NotYetAnalysed)
  end

  private

  def pick_database_configuration!
    @database = {
      file_name: @config[:database][:file],
      table_name: @config[:database][:key],
      columns: @config[:form][:input].inject({}) { |hash, input|
        hash.merge!(
          (input[:key] || (raise DBParameterMissing)) => (input[:type] || (raise DBParameterMissing))
        )
      }
    }
  end

  def pick_inquiry_configuration!
    @attributes = []
    @additional_attributes = []
    @validators = {}
    @inputs = {}

    @config[:form][:input].each do |input|
      key = input[:key].to_sym
      validators = {}

      @inputs.merge!(key => input[:item])

      if (validations = input[:validation]).is_a?(Array)
        validations.map { |validation|
          detect_validator(input, key, validation)
        }.each { |validator|
          validators.merge!(validator)
        }
      end

      if validators[:confirmation_target]
        confirmation_target = validators.delete(:confirmation_target).to_sym
        @additional_attributes.push(confirmation_target)
      end

      @validators.merge!(key => validators)
      @attributes.push(key)
    end
  end

  def message_or_boolean(message)
    message ? {message: message} : true
  end

  def detect_validator(input, key, validation)
    validators = {}

    case validation[:type].to_sym
      when :required
        validators.merge!(presence: message_or_boolean(validation[:message]))
      when :confirmation
        confirmation_key = "#{key }_confirmation"
        validators.merge!(confirmation: {message: validation[:message]})
        validators.merge!(confirmation_target: confirmation_key)
      when :length
        validators.merge!(length: {
                            message: validation[:message],
                            minimum: validation[:value][:min] || 0,
                            maximum: validation[:value][:max] || 1000,
                            allow_blank: true
                          })
      when :select_one
        validators.merge!(inclusion: {
                            message: validation[:message],
                            in: input[:item],
                            allow_blank: true
                          })
      when :select_any
        validators.merge!(select_any: {
                            message: validation[:message],
                            in: input[:item],
                          })
      else
        nil
    end

    validators
  end

  def normalize_template_path!
    @template = {}

    %w(form thank reply_mail admin_mail).each do |name|
      path = Pathname.new(File.expand_path @root) + @config[:template][name.to_sym]
      raise RequiredFileNotExist unless File.exist?(path)
      @template.merge!(name.to_sym => path)
    end
  end

  def has_required_value?
    trace(@config, required_key_value)
  end

  def trace(required, req)
    req.each_pair do |key, values|
      raise NotHasRequired unless required[key].is_a?(Hash)

      values.each do |value|
        raise NotHasRequired unless required[key][value]
      end
    end
  end

  def required_key_value
    {
      database: [:key, :file],
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
