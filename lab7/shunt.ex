defmodule Shunt do
  def test do
    start_state = {[:c, :a, :b], [],[]}
    end_state = {[:c, :b, :a], [],[]}
    moves=few(start_state, end_state)
    moves=compress(moves)
    states=Moves.sequence(moves, start_state)
    {:result, {:moves, moves}, {:states, states}}
  end

  def test_rand_state_gen(size) do
    wagons = Enum.map(0..(size - 1), fn e-> to_string(e)|>String.to_atom() end)
    index_set = Enum.map(1..size, fn e-> e end)
    pos_map = fn -> Enum.reduce(wagons, {index_set,%{}}, fn e, {i, map}->
      rand_i = Enum.random(i)
      {i--[rand_i], Map.put(map, rand_i, e)}
    end)|> (fn {_, map} -> Enum.map(map, fn {_, w}-> w end) end).() end
    {{pos_map.(),[],[]}, {pos_map.(), [],[]}}
  end

  def find({[],_,_}, {[],_,_}) do [] end
  def find({xs, [], []}, {ys, [], []}) do
    taken = Train.take(ys, 1)
    [taken_atom|_]=taken
    {hs, ts} = Train.split(xs, taken_atom)

    m0=Train.append(taken, ts)|>Train.position(nil)
    m1=(Train.position(hs, nil))

    {m, _, _} = {Train.append(taken, ts)|>Train.append(hs), [], []}
    [{:one, m0}, {:two, m1}, {:one, -m0}, {:two, -m1}|
    find({Train.drop(m, 1), [], []}, {Train.drop(ys, 1), [],[]})]
  end

  def few({[],_,_}, {[],_,_}) do [] end
  def few({xs, [], []}, {ys, [], []}) do
    taken = Train.take(ys, 1)
    [taken_atom|_]=taken
    case Train.split(xs, taken_atom) do
      {[], _} ->
        few({Train.drop(xs, 1), [],[]}, {Train.drop(ys, 1), [], []})
      {hs, ts} ->
        m0=Train.append(taken, ts)|>Train.position(nil)
        m1=(Train.position(hs, nil)) #gives length of train

        {m, _, _} = {Train.append(taken, ts)|>Train.append(hs), [], []}
        [{:one, m0}, {:two, m1}, {:one, -m0}, {:two, -m1}|
        few({Train.drop(m, 1), [], []}, {Train.drop(ys, 1), [],[]})]
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
  def rules([{track, 0}|t]) do rules(t) end
  def rules([{track, n}|[{track, m}|t]]) do
    [{track, n + m}| rules(t)]
  end
  def rules([curr|t]) do [curr|rules(t)] end
end
