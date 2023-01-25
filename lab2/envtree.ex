defmodule EnvTree do
  @type mnode :: {any(), any(), mnode(), mnode()}
  | nil

  def testMap() do
    m = new()
    m = add(m, 11, :y)
    m = add(m, 7, :z)
    m = add(m, 1, :v)
    m = add(m, 4, :x)
    m = add(m, 9, :o)
    m = add(m, 14, :u)
    m
  end

  @spec new()::mnode()
  def new() do nil end

  @spec add(mnode(), any(), any())::mnode()
  def add(nil, k, v) do {k, v, nil, nil} end
  def add({k, _, left, right}, k, v) do {k, v, left, right} end
  def add({n_k, n_v, left, right}, k, v) when k < n_k do {n_k, n_v, add(left, k, v), right} end
  def add({n_k, n_v, left, right}, k, v) when k > n_k do {n_k, n_v, left, add(right, k, v)} end

  @spec lookup(mnode(), any())::tuple()
  def lookup(nil, _) do nil end
  def lookup({k, v, _, _}, k) do {k, v} end
  def lookup({n_k, _, left, _}, k) when k < n_k do lookup(left, k) end
  def lookup({n_k, _, _, right}, k) when k > n_k do lookup(right, k) end

  @spec remove(mnode(), any())::mnode()
  def remove(nil, _) do nil end
  def remove({k, _, nil, nil}, k) do nil end
  def remove({k, _, left, nil}, k) do left end
  def remove({k, _, nil, right}, k) do right end
  def remove({k, _, left, right}, k) do
    {max_k, max_v} = find_max(left)
    {max_k, max_v, remove(left, max_k), right}
  end
  def remove({n_k, v, left, right}, k) when k < n_k do {n_k, v, remove(left, k), right} end
  def remove({n_k, v, left, right}, k) when k > n_k do {n_k, v, left, remove(right, k)} end

  @spec find_max(mnode())::any()
  def find_max (nil) do nil end
  def find_max ({k, v, _, nil}) do {k, v} end
  def find_max ({_, _, _, right}) do find_max(right) end
end
