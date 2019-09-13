class BinaryHash < ActiveRecord::Type::Binary
  def serialize(value)
    super value_to_binary(value.ensure_utf8.to_json)
  end

  def deserialize(value)
    super case value
          when NilClass
            {}
          when ActiveModel::Type::Binary::Data
            value_to_hash(value.to_s)
          else
            value_to_hash(PG::Connection.unescape_bytea(value))
          end
  end

  private

  def value_to_hash(value)
    JSON.parse(ActiveSupport::Gzip.decompress(value), symbolize_names: true) || {}
  end

  def value_to_binary(value)
    ActiveSupport::Gzip.compress(value)
  end
end

class Object
  def ensure_utf8
    case self
    when Hash
      each_with_object({}) do |(k, v), result|
        result[k] = v.ensure_utf8
      end
    when Array
      map(&:ensure_utf8)
    when String
      force_encoding(Encoding::UTF_8)
    else
      self
    end
  end
end
