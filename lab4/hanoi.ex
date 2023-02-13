defmodule Hanoi do
  @type peg :: atom()
  @type move :: {:move, peg(), peg()}| list(move())
  @type peg_mapping :: {atom(), atom()}

  @spec hanoi(number(), peg(), peg(), peg())::move()
  def hanoi(0, _, _, _) do [] end
  def hanoi(n, from, aux, to) do
    hanoi(n - 1, from, to, aux) ++ [{:move, from, to}] ++ hanoi(n - 1, aux, from, to)
  end

  def hanoi_move_count(0, _, _, _) do 0 end
  def hanoi_move_count(n, from, aux, to) do
    hanoi_move_count(n - 1, from, to, aux) + hanoi_move_count(n - 1, aux, from, to) + 1
  end


end
