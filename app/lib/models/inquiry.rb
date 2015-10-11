class Inquiry
  include ActiveModel::Model
  include ActiveModel::Validations
  include DynamicInjector

  class << self
    def ready(configure)
      return if @initialized

      inject_validators(configure.validators)
      inject_attributes(*(configure.attributes + [:token]))

      @initialized = true
    end
  end
end

