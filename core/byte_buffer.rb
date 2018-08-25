module Foundation
  class ByteBuffer
    # ByteBuffer is just a very big string with Binary Encoding.
    # We need to track position inside this string, limit and capacity.
    #
    #
    #
    attr_reader :position, :limit, :capacity

    def initialize(capacity)
      @capacity = capacity
      @buffer = ("\0" * @capacity).force_encoding(Encoding::BINARY)
    end
  end
end

# That's kinda like unit tests.
buffer = Foundation::ByteBuffer.new(16384)
