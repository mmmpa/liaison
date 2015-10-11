module DynamicInjector
  def self.included(klass)
    klass.class_eval do
      class << klass
        #プロパティを追加する。
        def inject_attributes(*attribute_names)
          class_eval do
            attr_accessor *attribute_names
          end
        end

        #バリデーションを追加する。
        def inject_validators(configs)
          class_eval do
            configs.each_pair do |attribute_name, validators|
              if (select_any = validators.delete(:select_any))
                add_validation_select_any(attribute_name, select_any)
              end
              validates(attribute_name, **validators) if validators != {}
            end
          end
        end

        private

        def add_validation_select_any(attribute_name, select_any)
          class_eval do
            validate ->(this) {
              raw_value = this.send(attribute_name)
              values = if raw_value.blank?
                            []
                          elsif !raw_value.is_a?(Array)
                            [raw_value]
                          else
                            raw_value
                          end
              values.each do |value|
                unless select_any[:in].include?(value)
                  this.errors.add(attribute_name, select_any[:message] || :invalid)
                  return false
                end
              end

              true
            }
          end
        end
      end
    end
  end
end