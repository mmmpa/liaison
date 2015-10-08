module ARConfigurationInjector
  def self.included(klass)
    klass.class_eval do
      class << klass
        #プロパティを追加する。基本不要。
        def inject_attributes(*attribute_names)
          class_eval do
            attr_accessor *attribute_names
          end
        end

        #バリデーションを追加する。
        def inject_validators(configurations)
          class_eval do
            configurations.each_pair do |attribute_name, validators|
              if (select_any = validators.delete(:select_any))
                add_validation_select_any(attribute_name, select_any)
              end
              validates(attribute_name, **validators) if validators != {}
            end
          end
        end

        private

        def add_validation_select_any(attribute_name, select_any)
          # パラメーターは配列として扱われる
          class_eval <<-EOS
            def #{attribute_name}
              JSON.parse(self[:#{attribute_name}])
            rescue
              []
            end

            def #{attribute_name}=(value)
              arralized = value.is_a?(Array) ? value : [value]
              self[:#{attribute_name}] = (JSON.generate(arralized))
            end
          EOS

          class_eval do
            validate ->(this){
              this.send(attribute_name).each do |value|
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