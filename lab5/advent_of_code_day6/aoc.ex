defmodule Aoc do
  @type size::{:size, integer()}
  @type pair::{any(), any()}
  @type queue::{size(), list(pair)}

  def solve_aoc_day_6_part1() do
    input_file_path = "input.txt"
    {status, data} = File.read(input_file_path)
    if ^status = :ok do
      queue = {{:size, 0}, []}
      start_index = 1
      find_start_of_packet(data, queue, start_index)
    else
      {:error, "failed to read file"}
    end
  end

  @spec find_start_of_packet(binary(), queue(), integer())::integer()
  def find_start_of_packet(<< <<a::8, b::8, c::8, d::8 >>, rest::binary >>, {{:size, 0}, []}, start_index) do
    find_start_of_packet(rest, fill_queue([{a,start_index},{b,start_index + 1},{c,start_index + 2},{d,start_index + 3}], {{:size, 0},[]}), start_index)
  end
  def find_start_of_packet(<< <<a::8>>, rest::binary>>, q, start_index) do
    last_index = start_index + 3;
    q = dequeue(q, start_index)
    {{:size, n}, l} = enqueue(q, a ,last_index + 1)
    ((n === 4) && last_index + 1)|| find_start_of_packet(rest, {{:size, n}, l}, start_index + 1)
  end
  def find_start_of_packet(_,_,_) do -1 end

  @spec enqueue(queue(), any(), any())::queue()
  def enqueue({{:size, n},[]}, k, v) do {{:size, n + 1}, [{k, v}]} end
  def enqueue({size, [{k, _}| t]}, k, v) do {size, [{k,v}| t]} end
  def enqueue([{h_k, h_v}|t], k, v) do [{h_k, h_v}|enqueue(t, k, v)] end
  def enqueue({size, [{h_k, h_v}|t]}, k, v) do
    {new_size, q } = enqueue({size, t}, k, v)
    {new_size, [{h_k, h_v}|q]}
  end

  @spec dequeue(queue(), any())::queue()
  def dequeue({size, []}, v) do {size, []} end
  def dequeue({{:size, n},[{_, v}| t]}, v) do {{:size, n - 1}, t} end
  def dequeue({size, [{k, h_v}|t]}, v) do
    {new_size, q} = dequeue({size, t}, v)
    {new_size, [{k, h_v}|q]}
  end

  @spec fill_queue(list(pair), queue())::queue()
  def fill_queue([], q) do q end
  def fill_queue([{k,v}|t], q) do
    q = enqueue(q, k, v)
    fill_queue(t, q)
  end
end
