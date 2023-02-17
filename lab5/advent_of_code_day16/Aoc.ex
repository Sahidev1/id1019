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

  def run_test(t) do
    {f, m} = gen_data();
    traverse_graph([],f,m,0,0,t)
  end

  def map_graph(map, []) do map end
  def map_graph(map, [{v, rest}|t]) do
    new_map = map_graph(map, t)
    Map.put(new_map, v, rest)
  end




  def traverse_graph(path, curr_vertex, graph_map, flowrate, flow_tot, time) when time <= 0 do
    {flow_tot, flowrate, path}
  end
  def traverse_graph(path, curr_vertex, graph_map, flowrate, flow_tot, time) do
    #IO.inspect({curr_vertex ,time, path, flow_tot, flowrate})
    {flow, edges} = Map.get(graph_map, curr_vertex, nil)
    ret_not_open = Enum.map(edges, fn edge -> traverse_graph(path++[{curr_vertex, :closed}], edge, graph_map, flowrate, flow_tot + flowrate, time - 1) end)
    {fl, flr, fpath} = Enum.max_by(ret_not_open, fn {flow_tot, _, _} -> flow_tot end)
    if flow !== 0 and !is_valve_open(curr_vertex, path) and time > 1 do
      ret_open = Enum.map(edges, fn edge -> traverse_graph(path++[{curr_vertex, :opened}], edge, graph_map, flowrate + flow, flow_tot + 2 * flowrate, time - 2) end)
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

  def is_valve_open(v,[]) do false end
  def is_valve_open(v,[{v, :opened}|t]) do true end
  def is_valve_open(v, [{v, :closed}|t]) do false end
  def is_valve_open(v, [{dv, _}|t]) do is_valve_open(v, t) end
end
