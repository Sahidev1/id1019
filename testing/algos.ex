defmodule Algos do

  #complexity 1 + 2 + 3 + ... (n - 1) + n = (n+1)/2 -> O(n²)
  def reverse ([]) do [] end
  def reverse ([h|t]) do
    reverse(t)++[h]
  end

  #complexity O(n)
  def reverse([], acc) do acc end
  def reverse([h|t], acc) do
    reverse(t, [h|acc])
  end

  #def test
  def tester(f, list) do
    :timer.tc(f, list)
  end
end
