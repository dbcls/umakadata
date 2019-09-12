class BinaryHash < ActiveRecord::Type::Binary
  def serialize(value)
    super value_to_binary(ensure_utf8(value).to_json)
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

  def ensure_utf8(value)
    case value
    when Hash
      value.each_with_object({}) do |(k, v), result|
        result[k] = ensure_utf8(v)
      end
    when Array
      value.map { |e| ensure_utf8(e) }
    when String
      value.force_encoding(Encoding::UTF_8)
    else
      value
    end
  end
end
