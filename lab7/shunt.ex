defmodule Shunt do
  def test do
    start_state = {[:c, :a, :b, :d], [],[]}
    end_state = {[:d, :c, :b, :a], [],[]}
    moves=few(start_state, end_state)
    moves=compress(moves)
    states=Moves.sequence(moves, start_state)
    {:result, {:moves, moves}, {:states, states}}
  end

  def find({[],_,_}, {[],_,_}) do [] end
  def find({xs, [], []}, {ys, [], []}) do
    taken = Train.take(ys, 1)
    [taken_atom|_]=taken
    {hs, ts} = Train.split(xs, taken_atom)

    m0=Train.append(taken, ts)|>Train.position(nil)
    m1=(Train.position(hs, nil))
    moves = [{:one, m0}, {:two, m1}, {:one, -m0}, {:two, -m1}]

    {m, _, _} = {Train.append(taken, ts)|>Train.append(hs), [], []}
    moves++find({Train.drop(m, 1), [], []}, {Train.drop(ys, 1), [],[]})
  end

  def few({[],_,_}, {[],_,_}) do [] end
  def few({xs, [], []}, {ys, [], []}) do
    taken = Train.take(ys, 1)
    [taken_atom|_]=taken
    case Train.split(xs, taken_atom) do
      {[], _} ->
        []++few({Train.drop(xs, 1), [],[]}, {Train.drop(ys, 1), [], []})
      {hs, ts} ->
        m0=Train.append(taken, ts)|>Train.position(nil)
        m1=(Train.position(hs, nil))
        moves = [{:one, m0}, {:two, m1}, {:one, -m0}, {:two, -m1}]

        {m, _, _} = {Train.append(taken, ts)|>Train.append(hs), [], []}
        moves++few({Train.drop(m, 1), [], []}, {Train.drop(ys, 1), [],[]})
    end
  end

  def compress(moves) do
    c_moves = rules(moves)
    if c_moves == moves do
      moves
    else
      compress(c_moves)
    end
  end

  def rules([]) do [] end
  def rules([curr|[]]) do
    case curr do
      {_, 0}->[]
      _-> [curr]
    end
  end
  def rules([curr|[next|t]]) do
    case {curr, next} do
        {{track, n}, {track, m}}-> [{track, n + m}|rules(t)]
        {{_, 0}, _}-> [next|rules(t)]
        _->[curr|rules([next|t])]
    end
  end
end
