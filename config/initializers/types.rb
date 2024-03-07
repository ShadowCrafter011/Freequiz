require "binary_hash"

ActiveRecord::Type.register(:binary_hash, BinaryHash)
