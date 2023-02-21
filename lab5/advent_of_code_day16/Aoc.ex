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
    traverse_graph([], first, m, 0,0,t, %{})
  end

  def run_test(t) do
    {f, m} = gen_data();
    traverse_graph([],f,m,0,0,t, %{})
  end

  def map_graph(map, []) do map end
  def map_graph(map, [{v, rest}|t]) do
    new_map = map_graph(map, t)
    Map.put(new_map, v, rest)
  end




  def traverse_graph(path, curr_vertex, graph_map, flowrate, flow_tot, time, valvestate) when time <= 0 do
    {flow_tot + flowrate, flowrate, path}
  end
  def traverse_graph(path, curr_vertex, graph_map, flowrate, flow_tot, time, valvestate) do
    #IO.inspect({curr_vertex ,time, path, flow_tot, flowrate})
    {flow, edges} = Map.get(graph_map, curr_vertex, nil)
    ret_not_open = Enum.map(edges, fn edge -> traverse_graph(path++[curr_vertex], edge, graph_map, flowrate, flow_tot + flowrate, time - 1, put_v_state(curr_vertex, valvestate, :closed)) end)
    {fl, flr, fpath} = Enum.max_by(ret_not_open, fn {flow_tot, _, _} -> flow_tot end)
    if flow !== 0 and !is_v_open(curr_vertex, valvestate) and time > 1 do
      ret_open = Enum.map(edges, fn edge -> traverse_graph(path++[curr_vertex], edge, graph_map, flowrate + flow, flow_tot + 2 * flowrate, time - 2, put_v_state(curr_vertex, valvestate, :opened)) end)
      {fo, rate, opath} = Enum.max_by(ret_open, fn {ft, _, _} -> ft end)
      if fo > fl do
        {fo, rate, opath}
      else
        {fl, flr, fpath}
      end
    else
      {fl, flr,fpath}
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

  def is_valve_open(v, p) do valve_state(v,p) === :opened end
  def valve_state(v,[]) do :closed end
  def valve_state(v,[{v, :opened}|t]) do :opened end
  def valve_state(v, [{v, :closed}|t]) do :closed end
  def valve_state(v, [{dv, _}|t]) do valve_state(v, t) end
end
