class BinaryHash < ActiveRecord::Type::Binary
    def type
        :binary_hash
    end
    
    def serialize(value)
        super value_to_binary(value.to_json)
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
        JSON.parse(
            ActiveSupport::Gzip.decompress(value),
            symbolize_names: true
        ) || {}
    end

    def value_to_binary(value)
        ActiveSupport::Gzip.compress(value)
    end
end