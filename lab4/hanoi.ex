defmodule Hanoi do
  @type peg :: atom()
  @type move :: {:move, peg(), peg()} | list(move())

  @spec hanoi(number(), peg(), peg(), peg())::move()
  def hanoi(0, _, _, _) do [] end
  def hanoi(n, from, aux, to) do
    hanoi(n - 1, from, to, aux) ++ [{:move, from, to}] ++ hanoi(n - 1, aux, from, to)
  end

  def hanoi_solve_moves(0, _, _, _) do 0 end
  def hanoi_solve_moves(n, from, aux, to) do
    hanoi_solve_moves(n - 1, from, to, aux) + 1 + hanoi_solve_moves(n - 1, aux, from, to)
  end
end
