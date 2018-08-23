module Core
  class ByteBuffer
    # ByteBuffer is just a very big string with Binary Encoding.
    # We need to track position inside this string, limit and capacity.
    #
    #
    #
    attr_reader :position, :limit, :capacity

    def intitialize(capacity)
      @capacity = capacity
      @buffer = ("\0" * @capacity).force_encoding(Encoding::BINARY)
    end
  end
end
