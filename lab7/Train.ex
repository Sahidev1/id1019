defmodule Train do
  @type wagon()::atom()
  @type train()::list(wagon())

  def take(_, 0) do [] end
  def take([h|t], n) do [h|take(t, n - 1)] end

  def drop(train, 0) do train end
  def drop([h|t], 1) do t end
  def drop([h|t], n) do drop(t, n - 1) end

  def append([],[]) do [] end
  def append([], [h|t]) do [h|append([],t)] end
  def append([h|t], train1) do [h|append(t, train1)] end

  def member([], _) do false end
  def member([y|_], y) do true end
  def member([_|t], y) do member(t, y) end

  def position([], y) do raise("atom "<>":"<>to_string(y)<>" is not a wagon of the train") end
  def position([y|_], y) do 1 end
  def position([x|t], y) do position(t, y) + 1 end

  def split([], y) do raise("atom "<>":"<>to_string(y)<>" is not a wagon of the train") end
  def split(train=[y|t], y) do {[], t} end
  def split(train=[x|t], y) do
    {left_t, right_t} = split(t, y)
    {[x|left_t], right_t}
  end

  def main([], n) do {n, [], []} end
  def main([h|t], n) do
    {k, rem, take} = main(t, n)
    cond do
      k > 0-> {k - 1, rem, [h|take]}
      true->{k, [h|rem], take}
    end
  end
end
