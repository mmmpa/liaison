require 'pathname'

class Analyst
  def initialize(root, configuration)
    @root = root
    @configuration = configuration
  end

  def analyse
    has_required_value?
    file_exist?
    @result = @configuration

    self
  end

  def result
    @result || (raise NotYetAnalysed)
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

  class NotYetAnalysed < StandardError
  end
  class NotHasRequired < StandardError
  end
  class RequiredFileNotExist < StandardError
  end

end
