defmodule Benchmark do

  @spec bench(atom() ,integer(), integer()) :: tuple()
  def bench(env, i, n) do
    seq = Enum.map(1..i, fn(_) -> :rand.uniform(i) end)

    list = Enum.reduce(seq, env.new(), fn(e, list) ->
      env.add(list, e, :foo)
    end)
    #generate n random numbers in the range [1,i]
    seq = Enum.map(1..n, fn(_) -> :rand.uniform(i) end)

    {add, _} = :timer.tc(fn() ->
      Enum.each(seq, fn(e) ->
        env.add(list, e, :foo)
      end)
    end)

    {lookup, _} = :timer.tc(fn() ->
      Enum.each(seq, fn(e) ->
        env.lookup(list, e)
      end)
    end)

    {remove, _} = :timer.tc(fn() ->
      Enum.each(seq, fn(e) ->
        env.remove(list, e)
      end)
    end)
    {i, n, add, lookup, remove}
  end

  @spec bench(atom(), integer())::any()
  def bench(env, n) do
    ls = [16,32,64,128,256,512,1024,2*1024,4*1024,8*1024, 16*1024, 32*1024, 64*1024]

    :io.format("# benchmark with ~w operations, time per operation in us\n", [n])
    :io.format("~6.s~12.s~12.s~12.s\n", ["n", "add", "lookup", "remove"])

    Enum.each(ls, fn (i) ->
      {i,_,t_add, t_look, t_rm} = bench(env, i, n)
      :io.format("~6.w~12.2f~12.2f~12.2f\n", [i, t_add/n, t_look/n, t_rm/n])
    end)
  end

  @spec ops_bench(atom(), integer())::any()
  def ops_bench(env, map_size) do
    ops = [16,32,54,128,512,1024,2*1024,4*1024, 8*1024, 16*1024]
    :io.format("# benchmark with ~w sized map, time of all operatins us\n", [map_size])
    :io.format("~6.s~12.s~12.s~12.s\n", ["n", "add", "lookup", "remove"])
    Enum.each(ops, fn (i) ->
      {_, i, t_add, t_look, t_rm} = bench(env, map_size, i)
      :io.format("~6.w~12.2f~12.2f~12.2f\n", [i, t_add/1, t_look/1, t_rm/1])
    end)
  end
end
