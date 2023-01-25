defmodule EnvList do
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

  def new() do [] end

  # we add elements so that sorting is maintained
  # the benefit of sorted list implementation of a map is that
  # you do not need to look up entire list for already existing keys on add operations
  def add([], key, value) do [{key, value}] end
  def add([{key, _}|t], key, value) do [{key, value}|t] end
  def add([{hkey,v}|t], key, value) when key < hkey do [{key, value}|[{hkey,v}|t]] end
  def add([{hkey, v}| t], key, value) do [{hkey,v}|add(t, key, value)] end

  def lookup([], _) do nil end
  def lookup([{key, val}|_], key) do {key, val} end
  def lookup([_|t], key) do lookup(t, key) end

  def remove([], _) do [] end
  def remove([{key, _}|t], key) do t end
  def remove([h|t], key) do [h|remove(t, key)] end
end
