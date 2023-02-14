defmodule Aoc do
  @type size::{:size, integer()}
  @type pair::{any(), any()}
  @type queue::{size(), list(pair)}

  def solve_aoc_day_6() do
    {:ok, data} = File.read("input.txt")
    queue = {{:size, 0}, []}
    {{"start of packet",find_sequential_match(data, queue, 1, 1, 4)},{"start of message", find_sequential_match(data, queue, 1, 1, 14)}}
  end

  @spec find_sequential_match(binary(), queue(), integer(), integer(), integer())::integer()
  def find_sequential_match(<< <<a::8>>, rest::binary>>, {{:size, 0}, []}, start_index, last_index, hit_size) do
    find_sequential_match(rest, enqueue({{:size, 0}, []}, a, start_index), start_index, last_index, hit_size)
  end
  def find_sequential_match(<< <<a::8>>, rest::binary>>, q, start_index, last_index, hit_size) when last_index < hit_size do
    {{:size, n}, l} = enqueue(q, a, last_index + 1)
    (n === hit_size && last_index + 1) || find_sequential_match(rest, {{:size, n}, l}, start_index , last_index + 1, hit_size)
  end
  def find_sequential_match(<< <<a::8>>, rest::binary>>, q, start_index, last_index, hit_size) do
    q = dequeue(q, start_index)
    {{:size, n}, l} = enqueue(q, a, last_index + 1)
    (n === hit_size && last_index + 1) || find_sequential_match(rest, {{:size, n}, l}, start_index + 1 , last_index + 1, hit_size)
  end
  def find_sequential_match(_,_,_,_,_) do -1 end

  @spec enqueue(queue(), any(), any())::queue()
  def enqueue({{:size, n},[]}, k, v) do {{:size, n + 1}, [{k, v}]} end
  def enqueue({size, [{k, _}| t]}, k, v) do {size, [{k,v}| t]} end
  def enqueue([{h_k, h_v}|t], k, v) do [{h_k, h_v}|enqueue(t, k, v)] end
  def enqueue({size, [{h_k, h_v}|t]}, k, v) do
    {new_size, q } = enqueue({size, t}, k, v)
    {new_size, [{h_k, h_v}|q]}
  end

  @spec dequeue(queue(), any())::queue()
  def dequeue({size, []}, _) do {size, []} end
  def dequeue({{:size, n},[{_, v}| t]}, v) do {{:size, n - 1}, t} end
  def dequeue({size, [{k, h_v}|t]}, v) do
    {new_size, q} = dequeue({size, t}, v)
    {new_size, [{k, h_v}|q]}
  end
end
