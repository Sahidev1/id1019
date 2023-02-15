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

  def map_graph(map, []) do map end
  def map_graph(map, [{v, rest}|t]) do
    new_map = map_graph(map, t)
    Map.put(new_map, v, rest)
  end

  def traverse_graph(path, curr_vertex, graph_map, flowrate, flow_tot, time) when time <= 0 do
    {flow_tot, flowrate, path}
  end
  def traverse_graph(path, curr_vertex, graph_map, flowrate, flow_tot, time) do
    {flow, edges} = Map.get(graph_map, curr_vertex, nil)
    ret_not_open = Enum.map(edges, fn edge -> traverse_graph(path, edge, graph_map, flowrate, flow_tot + flowrate, time - 1) end)
    {fl, flr, fpath} = Enum.max_by(ret_not_open, fn {flow_tot, _, _} -> flow_tot end)
    #IO.puts("wowza")
    if flow !== 0 do
      ret_open = Enum.map(edges, fn edge -> traverse_graph(path, edge, graph_map, flowrate + flow, flow_tot + 2 * flowrate, time - 2) end)
      #IO.puts("jammy")
      {fo, rate, opath} = Enum.max_by(ret_open, fn {ft, _, _} -> ft end)
      if fo > fl do
        {fo, rate, path++[curr_vertex]++opath}
      else
        {fl, flr, path++[curr_vertex]++fpath}
      end
    else
      {fl, flr, path++[curr_vertex]++fpath}
    end
  end
end
