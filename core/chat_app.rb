# Authors note:
# I think the maximum size of code snippet is this one
# We should avoid EventEmitter for now. Just use placeholder.
# I think it would be enough to use Stream and EV with callbacks.


class Stream
  def initialize(socket)
    @socket = socket
    # Store outgoing data in this String
    @writebuffer = ""
  end

  def _callbacks
    @_callbacks ||= Hash.new { |h, k| h[k] = [] }
  end

  def register_callback_for(type, &callback)
    _callbacks[type] << callback
    self
  end

  def run_registered_callbacks_for(type, *args)
    _callbacks[type].each do |callback|
      callback.call(*args)
    end
  end

  def <<(chunk)
    # Just append chunk to buffer,
    # `handle_write` will make an actual write.
    @writebuffer << chunk
  end

  def handle_read
    chunk = @socket.read_nonblock(4096)
    run_registered_callbacks_for(:data, chunk)
  rescue IO::WaitReadable
    # Oops, IO wasn't readable for some reason
    # let's ignore read and wait for the next time
  rescue EOFError, Errno::ECONNRESET
    # IO was closed by client
    run_registered_callbacks_for(:close)
  end

  def handle_write
    return if @writebuffer.empty?
    # write_nonblock will tell us how many bytes
    # were successfuly written.
    length = @socket.write_nonblock(@writebuffer)
    # Remove the data which that was successfuly written
    @writebuffer.slice!(0, length)
    # Run callbacks for `drain` event if there's nothing more to write
    run_registered_callbacks_for(:drain) if @writebuffer.empty?
  rescue IO::WaitWritable
  rescue EOFError, Errno::ECONNRESET
    run_registered_callbacks_for(:close)
  end

  def to_io
    @socket
  end
end

class Server
end

