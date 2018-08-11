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
  def receive_gift_for(gift_card)
    ...
  end
end
```

- But is it possible in Ruby? Asked the developer-leader of GiftApplication. She was frustrated as all her team.
- I don't know. The ancient master of `libev` did leave us a couple of keys to grok this, but you and your team should have patience.
- We'll do our best, wizard.


# In the heart of Ruby.


