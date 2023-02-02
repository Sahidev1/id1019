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
    bindings = [{{:var, :x},{:num, 3}}, {{:var, :y}, {:q, 7, 3}}, {{:var, :z}, {:num, 11}}]
    env = create_env(bindings)
    ex0 = {:add, {:add, {:var, :x}, {:num, 2}}, {:add, {:var, :y}, {:q, 4, 7}}}
    ex1 = {:sub, {:add, {:var, :x}, {:num, 2}}, {:sub, {:var, :y}, {:q, 4, 7}}}
    {eval(ex0, env), eval(ex1, env)}
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
  def eval({:q, n, m}, _) do {:q, n, m} end
  def eval({:var, v}, env) do find_bind(env, {:var, v}) end
  def eval({:add, e0, e1}, env) do
    add(eval(e0, env), eval(e1, env))
  end
  def eval({:sub, e0, e1}, env) do
    ev1 = eval(e1, env)
    case ev1 do
      {:num, n}-> add(eval(e0, env), {:num, -n})
      {:q, n, m}->add(eval(e0, env), {:q, -n, m})
    end
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
    l = lcm(m0, m1)
    {:q, n0, m0} = {:q, n0*(div(l, m0)), l}
    {:q, n1, m1} = {:q, n1*(div(l, m1)), l}
    cond do
      rem(n0 + n1, l) === 0-> {:num, div(n0 + n1, l)}
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
