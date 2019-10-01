class JsonArray < ActiveRecord::Type::String
  def serialize(value)
    super case value
          when Array
            value.to_json
          else
            value
          end
  end

  def deserialize(value)
    case value
    when NilClass
      []
    else
      begin
        JSON.parse(value)
      rescue
        []
      end
    end
  end
end
