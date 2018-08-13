# Once upon a time. Async core.

Hi, folks!

Once upon a time people of Earth decided to build asyncronous libraries, so they can write code in nonblocking manner. They came a long road to this decision. They've been always writing straightforward code like this one for web-applications:

```ruby
class App
  def index
    user = DataBase.get_user
    gift = GiftApi.receive_gift_for(user.gift_card)
    respond gift
  end
end
```
But they've never could fight the dark side of this code. The `sleep`...

Many years ago this gift application became popular and people of Earth had to pay tremendous amount of money to the creature they asked to host this app - Amazonius.

The wizard of Earth scratched his had and his face shined, he knew the answer. People already had the answer, the answer to the question how to improve the speed of this application with minimal effort, with ancient magic.

```ruby
class App
  def index
    user = DataBase.get_user(params[:id]).wait
    gift = GiftApi.receive_gift_for(user.gift_card).wait
    respond gift
  end
end

class DataBase
  async def get_user(id)
    ...
  end
end

class GiftApi
  async def receive_gift_for(gift_card)
    ...
  end
end
```

- But is it possible in Ruby? Asked the developer-leader of GiftApplication. She was frustrated as all her team.
- I don't know. The ancient master of `libev` did leave us a couple of keys to grok this, but you and your team should have patience.
- We'll do our best, wizard.


# In the heart of Ruby.


Ruby creators left something for us, deep in the the heart of the language. `IO.select` (you can learn about this method in official documentation `https://ruby-doc.org/core-2.3.3/IO.html#method-c-select`) is not widely known or used part of the standard library but it is truly a gem we have to understand. After reading `select` documentation and staring at `async def hello` method description team decided to implement something. 

I remember the story about what it actually means to be asynchronous, one of the team members started his story:

```
A long time ago one wise man came up to me and asked what I am doing.

I was writing a simple code like this:
def text_handler
  text = io.read_line
  length = text.length
  length * 2
end

He smiled and asked me: Why are you waiting for this text?
- What?
- You wait for it.
- Yes, but I need this text to calculate the length and multiply by 2. How can I do this without a text?
- Truly, there is no way to do this without text, but why wouldn't you ask your program to run your code only when your text is ready? Like this:
def text_handler
  io.read_line do |text|
    length = text.length
    length * 2
  end
end

- Whoa, this is really weird, but how do my program know when to execute this code?
```

After he ended this story everyone were silent. Ephera sat down before her screen
and started to write the code, thinking loudly.

- In this situation we have some input-outup(IO) for example it might be STDOUT and STDIN, and we don't want to wait for something to appear there. What we really want is to have a piece of code, and when something appear in STDIN we want this code to be automaticaly runned.

```ruby
IO.select [STDIN], nil, nil, 10
```

Let's try to run this line of code in REPL.

```ruby
pry(main)> IO.select [STDIN], nil, nil, 10
10000
=> [[#<IO:<STDIN>>], [], []]
pry(main)> => 10000
```

What happened here? We started `select` and asked it to wait for 10 seconds for input in STDIN, we entered 10000 and got an array with this structure in response `[[#<IO:<STDIN>>], [], []]`. After this `pry` just output what we entered `pry(main)> => 10000`.


But what if we'll just wait for 10 seconds?
```ruby
pry(main)> IO.select [STDIN], nil, nil, 10
=> nil
```
What happened? We've got `nil` after 10 seconds of waiting.

But how to use it? Ephera tried to implement some code wich actually do nonblocking IO.
```ruby
def run
  readables, writeables, = IO.select [STDIN], nil, nil, 10
  
  if source = readables[0]
    puts source.read(6)
  end
end
```

```ruby
pry(main)> run 
Hello
Hello
=> nil
```

`IO.select` gives us a couple of values. `readables` are array of magical resources you can get some text from. `writeables` are those who are ready for you to write to.

`IO.select` magically stop the execution of your program and wait for something to become readable and writeable, after which it unblocks it and let the code below to run.

We know that we registered just one magical resource `STDIN` and after we enter `Hello` in pry session `IO.select` will react to it. 
```ruby
if source = readables[0] # we know that we only have STDIN here
  puts source.read(6) # yes, we are waiting for 6 bytes to read.
end
```

Let's take a closer look at `source.read(6)` line of code. This 6 is just plain weird.
In Ruby we have 4 options to work with IO objects.

```ruby 
io.read 
```
Reads until the IO is closed (e.g., end of file, server closes the connection, etc.)
If you want to try this out in your console(pry session) your best bet is to use Ctrl-D, it'll send EOF to your process.

```ruby 
io.read(6)
```
Reads until it has received exactly 6 bytes.

```ruby 
io.readpartial(6)
```
Waits until the IO becomes readable, then it reads at most 6 bytes.
So if a server sends only 3 bytes, readpartial will return those 3 bytes.
If you had used read(6), it would wait until 3 more bytes were sent.

```ruby 
io.read_nonblock(6)
```
Will read at most 6 bytes if the IO is readable. It raises IO::WaitReadable if the IO is not readable.

Let's rearange this a little bit
```ruby
def run
  readables, writeables, = IO.select [STDIN], nil, nil, 10
  
  if source = readables[0]
    puts source.read_nonblock(4096)
  end
end
```

```
pry(main)> run 
Hello
Hello
=> nil
```

Here we changed from using `read` to `read_nonblock`.

And we've got truly non-blocking code for our `STDIN`.

Wizard and Erea(lead) were skeptical about this design. 
```
- It looks really complecated. If we want to puts something to screen there are much
easier ways - told Erea.
- Yep, it reminds about this ancient fast code, but I have no idea where to code from here - told Wizard
```

We'll try to find where to go next. But for now, it was great that we found out what Ruby have prepared for us!


```
I think it's really hard to discuss all this async stuff with `STDIN` example. Maybe we should move to network IO, like HTTP? - said cat programmer(yeah, he's a smart one).
```

```ruby
require "socket" # we need `socket` to use TCPServer

server = TCPServer.new("0.0.0.0", 9234)

while io = server.accept # this is special function to accept connection at localhost:9234
  io << "HTTP/1.1 200 OK\r\n\r\nHello, world!"
  io.close
end
```

```
This is the simplest possible http server I can think about - cat started.
A truly remarkable thing here in my opinion is that HTTP before HTTP2 is simple text
protocol, so we can just send text to client "HTTP/1.1 200 OK\r\n\r\nHello, world!" - cat finished.
```

and I think we should move from here and discuss what we can actually do.
A classical example of how to use this cool select thing is chat server, let's try to make the simple one.

## Chat Server. Where cat introduce Stream, EventLoop and and nonblocking IO.

```ruby
# Authors note:
# I think the maximum size of code snippet is this one
# We should avoid EventEmitter for now. Just use placeholder.
# I think it would be enough to use Stream and EV with callbacks.


class Stream
  # we want to bind and emit events
  include EventEmitter

  def initialize(io)
    @io = io
    # Store outgoing data in this String
    @writebuffer = ""
  end

  def to_io
    @io
  end

  def <<(chunk)
    # just append this to buffer, handle_write
    # will make an actual write.
    @writebuffer << chunk
  end

  def handle_read
    chunk = @io.read_nonblock(4)
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
    length = @io.write_nonblock(@writebuffer)
    # Remove the data which that was successfuly written
    @writebuffer.slice!(0, length)
    # Emit `drain` event if there's nothing more to write
    emit(:drain) if @writebuffer.empty?
  rescue IO::WaitWritable
  rescue EOFError, Errno::ECONNRESET
    emit(:close)
  end
end
```


# TODO: Enhance this section or remove it, not usefull at all
It looks really weird and low-level for Ruby developer, the reason for this - it is really pretty low-level. This approach for programming reactions to some events originated from C programming language.

Let's look a bit at this ancient and forgotten spells:

- Select - operating system call.
- Poll - operating system call.
- Epoll - Linux have this unique mechanizm.
- Kqueue - OSX, BSD-based operating systems use this one.

You might be interested in libraries: 

- `libevent` (truly ancient)
- `libev` (Phusion Passenger web-server and libraries based on nio4r, including Async and Culluloid)
- `libuv` (Node.js powerfull async engine built on top of it!)
