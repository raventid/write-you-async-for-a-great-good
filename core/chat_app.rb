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

  # Let's avoid EventEmitter for now?
  # We already have it, so should we just avoid term?
  # Well, ok let's avoid it for now and call this
  # just callbacks, we have to introduce callbacks first.
  ## EVENTEMITTER START
  def _callbacks
    @_callbacks ||= Hash.new { |h, k| h[k] = [] }
  end

  def on(type, &blk)
    _callbacks[type] << blk
    self
  end

  def emit(type, *args)
    _callbacks[type].each do |blk|
      blk.call(*args)
    end
  end
  ## EVENTEMITTER END

  def to_io
    @socket
  end

  def <<(chunk)
    # just append this to buffer, handle_write
    # will make an actual write.
    @writebuffer << chunk
  end

  def handle_read
    chunk = @socket.read_nonblock(4096)
    # this need to be improved, emit(:close) just removes
    # clients from sever and EV lists, but does not close
    # socket, so client wait for some server reaction and
    # gets nothing in response.
    # emit(:close) if chunk.include?(":q")
    emit(:data, chunk)
  rescue IO::WaitReadable
    # Oops, IO wasn't readable, someone made a mistake
  rescue EOFError, Errno::ECONNRESET
    # IO was closed
    emit(:close)
  end

  def handle_write
    return if @writebuffer.empty?
    length = @socket.write_nonblock(@writebuffer)
    # Remove the data which that was successfuly written
    @writebuffer.slice!(0, length)
    # Emit `drain` event if there's nothing more to write
    emit(:drain) if @writebuffer.empty?
  rescue IO::WaitWritable
  rescue EOFError, Errno::ECONNRESET
    emit(:close)
  end
end

class Server
end

