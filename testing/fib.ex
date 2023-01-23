defmodule Fib do
  # nth fibonacci number
  def fib(0) do 0 end
  def fib(1) do 1 end
  def fib(n) do fib(n - 1) + fib(n - 2) end

  # generate list of fibonacci numbers up to n
  def fiblist(0) do [0] end
  def fiblist(1) do [1,0] end
  def fiblist(n) do
    l = fiblist(n - 1)
    [h0 | [h1|_]] = l
    [h1 + h0]++l
  end
end
