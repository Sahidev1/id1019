defmodule Aoc do
  @type size::{:size, integer()}
  @type pair::{any(), any()}
  @type queue::{size(), list(pair)}

  def solve_aoc_day_6() do
    {:ok, data} = File.read("input.txt")
    queue = {{:size, 0}, []}
    {{"start of packet",fsm(data, queue, 1, 1, 4)},{"start of message", fsm(data, queue, 1, 1, 14)}}
  end

  @spec fsm(binary(), queue(), integer(), integer(), integer())::integer()
  def fsm(<< <<a::8>>, rest::binary>>, {{:size, 0}, []}, st, li, hit_s) do
    fsm(rest, enqueue({{:size, 0}, []}, a, st), st, li, hit_s)
  end
  def fsm(<< <<a::8>>, rest::binary>>, q, st, li, hit_s) when li < hit_s do
    {{:size, n}, l} = enqueue(q, a, li + 1)
    (n === hit_s && li + 1)||fsm(rest, {{:size, n}, l}, st , li + 1, hit_s)
  end
  def fsm(<< <<a::8>>, rest::binary>>, q, st, li, hit_s) do
    q = dequeue(q, st)
    {{:size, n}, l} = enqueue(q, a, li + 1)
    (n === hit_s && li + 1)||fsm(rest, {{:size, n}, l}, st + 1 , li + 1, hit_s)
  end
  def fsm(_,_,_,_,_) do -1 end

  @spec enqueue(queue(), any(), any())::queue()
  def enqueue({{:size, n},[]}, k, v) do {{:size, n + 1}, [{k, v}]} end
  def enqueue({size, [{k, _}| t]}, k, v) do {size, [{k,v}| t]} end
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
