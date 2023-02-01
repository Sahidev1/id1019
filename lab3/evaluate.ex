defmodule Evaluate do
  @type variable() :: {:var, atom()}

  @type value() :: {:num, number()}
  | {:q, number(), number()}

  @type binding() :: {variable(), value()}
  | list(binding())

  @type literal() :: variable()
  | value()

  @type expr() :: {:add, expr(), expr()}
  | {:sub, expr(), expr()}
  | {:mul, expr(), expr()}
  | {:div, expr(), expr()}
  | literal()

  def test() do
    q0 = {:q, 2, 3}
    q1 = {:q, 11, 5}
    add(q0, q1)
  end

  @spec create_env(binding()) :: map()
  def create_env([]) do %{} end
  def create_env({var, val}) do
    Map.put(create_env([]), var, val)
  end
  def create_env([{key, val}|t]) do
    Map.put(create_env(t), key, val)
  end

  @spec find_bind(map(), variable()) :: any()
  def find_bind(map, var) do
    Map.get(map, var, nil)
  end

  @spec eval(expr(), map()) :: literal()
  def eval({:num, n}, _) do {:num, n} end
  def eval({:var, v}, env) do find_bind(env, {:var, v}) end
  def eval({:add, e0, e1}, env) do
    add(eval(e0, env), eval(e1, env))
  end
  def eval({:sub, e0, e1}, env) do

  end

  def add({:num, n0}, {:num, n1}) do {:num, n0 + n1} end
  def add({:q, n0, m}, {:num, n1}) do
    add({:q, n0, m}, {:q, n1 * m, m})
  end
  def add({:num, n0}, {:q, n1, m}) do add({:q, n1, m}, {:num, n0}) end
  def add({:q, n0, m0}, {:q, n1, m1}) do
    gcd0 = gcd(n0, m0)
    gcd1 = gcd(n1, m1)
    {:q, n0, m0} = {:q, div(n0, gcd0), div(m0, gcd0)}
    {:q, n1, m1} = {:q, div(n1, gcd1), div(m1, gcd1)}
    IO.inspect({:q, n0, m0})
    IO.inspect({:q, n1, m1})
    l = lcm(m0, m1)
    {:q, n0, m0} = {:q, n0*(div(l , m0)), l}
    {:q, n1, m1} = {:q, n1*(div(l, m1)), l}
    IO.inspect({:q, n0, m0})
    IO.inspect({:q, n1, m1})
    cond do
      #rem(n0 + n1, l) === 0-> {:num, div(n0 + n1, l)}
      true-> {:q, n0 + n1, l}
    end
  end

  @spec gcd(integer(), integer()) :: integer()
  def gcd(a, b) do
    m = rem(a, b)
    cond do
      m === 0-> b
      true-> gcd(b, m)
    end
  end

  @spec lcm(integer(), integer()) :: integer()
  def lcm(a, b) do
    g = gcd(a, b)
    l = div(a, g)*b
  end

end
