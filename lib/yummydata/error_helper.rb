module Yummydata
  module ErrorHelper

    def prepare
      @error = nil
    end

    def set_error(value)
      @error = value
    end

    def get_error
      return nil if @error.nil?

      error = @error.dup
      self.prepare
      return error
    end

  end
end
