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

```
IO.select [STDIN], nil, nil, 10
```

Let's try to run this line of code in REPL.

```
pry(main)> IO.select [STDIN], nil, nil, 10
10000
=> [[#<IO:<STDIN>>], [], []]
pry(main)> => 10000
```

What happened here? We started `select` and asked it to wait for 10 seconds for input in STDIN, we entered 10000 and got an array with this structure in response `[[#<IO:<STDIN>>], [], []]`. After this `pry` just output what we entered `pry(main)> => 10000`.


But what if we'll just wait for 10 seconds?
```
pry(main)> IO.select [STDIN], nil, nil, 10
=> nil
```
What happened? We've got `nil` after 10 seconds of waiting.
