module HighLevel
  class Awaiter
    # How to await multiple Fibers?
    # It's pretty straightforward, we just
    # have to run tasks one by, one and then
    # collect the result.
    def await
      children.collect(&:await)
    end
  end
end
