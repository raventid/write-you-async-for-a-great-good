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

    def <<(str)
      raise "expected String, got #{str.class}" unless str.respond_to?(:to_str)
      str = str.to_str

      # Available space in is easy to calculate,
      # it is maximal cursor position minus current cursor position
      available_space = @limit - @position

      raise "buffer overflow" if str.length > available_space

      # We have to select the part of byte_buffer
      # from current cursor position to str.length
      @buffer[@position...str.length] = str

      # Here we shift position by the length of string
      @position += str.length
      self
    end
  end
end

# That's kinda like unit tests.

# Let's create our byte buffer
buffer = Foundation::ByteBuffer.new(100)

buffer << "Hello"
