defmodule EnvWrap do
  def new() do %{} end
  def add(map, key, val) do Map.put(map, key, val) end
  def lookup(map, key) do Map.get(map, key, nil) end
  def remove(map, key) do Map.delete(map, key) end
end
