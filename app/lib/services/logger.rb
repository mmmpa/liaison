class Logger
  class << self
    def work!
      @enabled = true
    end

    def add(message)
      store.push(message)
    end

    def store
      @store ||= []
    end

    def write
      @enabled ? store.join : ''
    end
  end
end