defmodule Aoc do
  @type edge::atom()
  @type flow::integer()
  @type vertex::{atom(),{flow(), list(edge)}}
  @type graph::list(vertex)

  def gen_graph() do
    Parser.task()
  end

  def gen_data() do
    g = gen_graph();
    m = map_graph(%{},g)
    first = :FY
    {first, m}
  end

  def run_sample(t) do
    g = Parser.parse(Parser.sample())
    m = map_graph(%{}, g)
    first = :A
    mem = %{}
    traverse_graph([], first, m, 0,0,t, %{}, mem)
  end

  def run_test(t) do
    {f, m} = gen_data();
    traverse_graph([],f,m,0,0,t, %{}, %{})
  end

  def map_graph(map, []) do map end
  def map_graph(map, [{v, rest}|t]) do
    new_map = map_graph(map, t)
    Map.put(new_map, v, rest)
  end




  def traverse_graph(path, curr_vertex, graph_map, flowrate, flow_tot, time, valvestate, mem) when time <= 0 do
    {flow_tot + flowrate, flowrate, path, mem}
  end
  def traverse_graph(path, curr_vertex, graph_map, flowrate, flow_tot, time, valvestate, mem) do
    #IO.inspect({curr_vertex ,time, path, flow_tot, flowrate})
    foundmatch = Map.get(mem, {time, path++[curr_vertex]}, nil)
    case foundmatch do
      nil->
      {flow, edges} = Map.get(graph_map, curr_vertex, nil)

      {ret_not_open,mem} = Enum.map_reduce(edges,mem , fn edge,acc ->
        {t0, f0, p0, nmem} = traverse_graph(path++[curr_vertex], edge, graph_map, flowrate, flow_tot + flowrate, time - 1, put_v_state(curr_vertex, valvestate, :closed), acc)
        {{t0, f0, p0}, nmem}
      end)

      {fl, flr, fpath} = Enum.max_by(ret_not_open, fn {flow_tot, _, _} -> flow_tot end)
      if flow !== 0 and !is_v_open(curr_vertex, valvestate) and time > 1 do
        {ret_open, mem} = Enum.map_reduce(edges, mem ,fn edge, acc ->
          {t1,f1,p1, nmem}=traverse_graph(path++[curr_vertex], edge, graph_map, flowrate + flow, flow_tot + 2 * flowrate, time - 2, put_v_state(curr_vertex, valvestate, :opened), acc)
          {{t1, f1, p1}, nmem}
      end)
        {fo, rate, opath} = Enum.max_by(ret_open, fn {ft, _, _} -> ft end)
        if fo > fl do
          mem = Map.put(mem, {time, path++[curr_vertex]}, {fo - flow_tot, 2});
          {fo, rate, opath, mem}
        else
          mem = Map.put(mem, {time, path++[curr_vertex]}, {fl - flow_tot, 1});
          {fl, flr, fpath, mem}
        end
      else
        mem = Map.put(mem, {time, path++[curr_vertex]}, {fl - flow_tot, 1});
        {fl, flr,fpath, mem}
      end
      {val, minuend}->
        IO.puts("match")
        {val + flowrate * (time - minuend), flowrate, path, mem}
    end
  end

  def is_v_open(v, map) do get_v_state(v, map) === :opened end
  def put_v_state(v, map, notfound) do
    res = get_v_state(v, map);
    case res do
      :closed when notfound === :opened->
        map = Map.put(map, v, notfound)
        map
      :closed->map
      :opened->map
      nil->
        map = Map.put(map, v, notfound)
        map
    end
  end
  def get_v_state(v, vmap) do Map.get(vmap, v, nil) end


end
