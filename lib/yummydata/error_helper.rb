module Yummydata
  module ErrorHelper

    def prepare
      @errors = {} if @errors == nil
    end

    def set_error(key, value)
      self.prepare
      @errors[key] = value
    end

    def get_error(key)
      @errors[key]
    end

  end
end
