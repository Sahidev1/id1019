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
end
