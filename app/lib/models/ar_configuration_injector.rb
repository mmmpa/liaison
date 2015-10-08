module ARConfigurationInjector
  def self.included(klass)
    klass.class_eval do
      class << klass
        def inject_attributes(*attribute_names)
          class_eval do
            attr_accessor *attribute_names
          end
        end

        def inject_validators(configurations)
          class_eval do
            configurations.each_pair do |attribute_name, validators|
              validates(attribute_name, **validators) if validators != {}
            end
          end
        end
      end
    end
  end
end