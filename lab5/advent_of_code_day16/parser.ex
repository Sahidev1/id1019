defmodule Parser do

  def task() do
    start = :AA
    rows = File.stream!("input.txt")
    #rows = sample()
    parse(rows)
  end



  ## turning rows
  ##
  ##  "Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE"
  ##
  ## into tuples
  ##
  ##  {:DD, {20, [:CC, :AA, :EE]}
  ##

  def parse(input) do
    Enum.map(input, fn(row) ->
      [valve, rate, valves] = String.split(String.trim(row), ["=", ";"])
      [_Valve, valve | _has_flow_rate ] = String.split(valve, [" "])
      valve = String.to_atom(valve)
      {rate,_} = Integer.parse(rate)
      [_, _tunnels,_lead,_to,_valves| valves] = String.split(valves, [" "])
      valves = Enum.map(valves, fn(valve) -> String.to_atom(String.trim(valve,",")) end)
      {valve, {rate, valves}}
    end)
  end

  def sample() do
    ["Valve A has flow rate=0; tunnels lead to valves B, F",
     "Valve B has flow rate=2; tunnels lead to valves A, C",
     "Valve F has flow rate=1; tunnels lead to valves A, E",
     "Valve C has flow rate=0; tunnels lead to valves D, E, B",
     "Valve D has flow rate=0; tunnels lead to valves E, C",
     "Valve E has flow rate=3; tunnels lead to valves C, D, F"]
  end
end
