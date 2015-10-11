class InputDealer
  class << self
    def call(cgi)
      {
        method: detect_method(cgi),
        parameters: adjust_params(cgi),
        cookie_token: pick_token(cgi)
      }
    end

    def pick_token(cgi)
      cgi.cookies['token'].value.first
    rescue
      ''
    end

    def detect_method(cgi)
      (cgi.request_method || 'GET').downcase.to_sym
    end

    def adjust_params(cgi)
      (cgi.params || {}).each_pair.inject({}) { |a, (key, value)|
        a.update(key.to_s.gsub('[]', '').to_sym => shape(value))
      }.each_pair.inject({}) { |a, (key, value)|
        a.update(key.to_sym => shape(value))
      }
    end

    def shape(value)
      return value unless value.is_a?(Array)

      if value.size == 1
        value.first
      elsif value.size == 0
        nil
      else
        value
      end
    end
  end
end