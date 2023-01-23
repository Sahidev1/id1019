defmodule EnvList do
  def add(nil, key, value) do [{key, value}] end
  def add([], key, value) do [{key, value}] end
  def add(map, key, value) do
    [h|t] = map
    {hkey,_} = h
    cond do
      key < hkey -> [{key, value}|map]
      key > hkey -> [h|add(t, key, value)]
      key === hkey -> [{key, value}|t]
    end
  end

  def lookup([], _) do nil end
  def lookup([{key, val}|_], key) do {key, val} end
  def lookup([_|t], key) do lookup(t, key) end
end
