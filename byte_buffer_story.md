ByteBuffer is a simple piece of allocated memory. The simplest way to create buffer is just

```ruby
byte_buffer = ("\0" * @capacity).force_encoding(Encoding::BINARY)
```

So, what's going on here? Let's take a look at this.

"\0" - it's just null byte. It's the end of string in Unix systems.

To allocate the amount we need for this string, we multiply Null and @capacity.

String in Ruby (and many other languages) have an encoding property. We'll use BINARY
because we are not planning to store human readable strings here, just some data (which might be malformed or not completely readed from source yet)

So, our byte_buffer is pretty cool, but it's not very usable :(

What if we want to add some data to this storage? What if we want to read from it?

Let's introduce `<<` method! It's like adding something to array, but in our case we will be adding something to byte_buffer!

```ruby
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

```

Why not just create a new variable every time? Like this:

```ruby
something = read_some_information_from_some_source
```

There's a little problem here we might not notice from beginning. Everytime we create a variable we need a place in memory to save it's content. Despite the fact, that Ruby uses memory in a very sophisticated way, we still can spend some time trying to get a free memory slot from operating system. So what we do with byte-buffer is we just ask operating system to give us a really big piece of memory so we can use it to write some data to it and read from it. Now we never have to ask operating system for more memory and we do not spend any time doing this!
