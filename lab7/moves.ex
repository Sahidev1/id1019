defmodule Moves do
  @type state()::{Train.train(), Train.train(), Train.train()} # {main, one, two}
  @type move()::{:one, integer()}
  |{:two, integer()}

  def gen_test_state do
    {[:a, :b], [:c, :d],[:e]}
  end

  #moves explanation
  # {a, 3} move 3 right most wagons from main to track a
  # {a, -3} move 3 left most wagons from track a to main

  def single({:one, n}, {main, one, two}) do
    {main, one} = single(n, {main, one})
    {main, one, two}
  end
  def single({:two, n}, {main, one, two}) do
    {main, two} = single(n, {main, two})
    {main, one, two}
  end
  def single(n, {main, track}) do
    cond do
      n == 0->{main, track}
      n > 0->
        {k, remaining, taken} = Train.main(main, n)
        {remaining, Train.append(track, taken)}
      true->
        taken = Train.take(track, abs(n))
        {Train.append(main, taken), Train.drop(track, abs(n))}
    end
  end

  def sequence([], state) do [state] end
  def sequence([{move, n}|t], state={main, one, two}) do
    [state| sequence(t, single({move, n},state))]
  end
end
