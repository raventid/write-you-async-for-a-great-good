ByteBuffer is a simple piece of allocated memory. The simplest way to create buffer is just

```ruby
byte_buffer = ("\0" * @capacity).force_encoding(Encoding::BINARY)
```

So, what's going on here? Let's take a look at this.

"\0" - it's just null byte. It the end of string in Unix systems.

To allocate the amount we need for this string, we multiply Null and @capacity.

String in Ruby (and many other languages) can have an encoding characteristics. Will use BINARY
because we are not planning to store human readable strings here, just some data (which might be malformed or not completely readed from source yet)
