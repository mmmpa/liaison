class Analyst
  def initialize(configuration)
    @configuration = configuration
  end

  def analyse
    has_required_value?
    file_exist?

    true
  end

  def file_exist?

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
      template: [:directory, :form, :thank, :reply_mail, :admin_mail],
      form: [:input]
    }
  end

  class NotHasRequired < StandardError
  end
  class RequiredFileNotExist < StandardError
  end

end
