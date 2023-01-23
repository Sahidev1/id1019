defmodule EnvList do
  def testMap() do
    m = add(nil, 4, :x)
    m = add(m, 11, :y)
    m = add(m, 7, :z)
    m = add(m, 1, :v)
    m
  end

  def add(nil, key, value) do [{key, value}] end
  def add([], key, value) do [{key, value}] end
  def add([{key, _}|t], key, value) do [{key, value}|t] end
  def add([{hkey,v}|t], key, value) when key < hkey do [{key, value}|[{hkey,v}|t]] end
  def add([{hkey, v}| t], key, value) do [{hkey,v}|add(t, key, value)] end

  def lookup([], _) do nil end
  def lookup([{key, val}|_], key) do {key, val} end
  def lookup([_|t], key) do lookup(t, key) end
end
