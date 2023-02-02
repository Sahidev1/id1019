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
    ex2 = {:mul, {:add, {:var, :x}, {:num, 2}}, {:sub, {:var, :y}, {:q, 2, 3}}}
    # ((x+2)*(y - 2/3))/(z+3/4)
    ex3 = {:div, {:mul, {:add, {:var, :x}, {:num, 2}}, {:sub, {:var, :y}, {:q, 2, 3}}}, {:add, {:var, :z}, {:q, 3, 4}}}
    {eval(ex0, env), eval(ex1, env), eval(ex2, env), eval(ex3, env)}
  end

  @spec create_env(binding()) :: map()
  def create_env([]) do %{} end
  def create_env({var, val}) do Map.put(create_env([]), var, val) end
  def create_env([{key, val}|t]) do Map.put(create_env(t), key, val) end

  @spec find_bind(map(), variable()) :: any()
  def find_bind(map, var) do Map.get(map, var, nil) end

  @spec eval(expr(), map()) :: literal()
  def eval({:num, n}, _) do {:num, n} end
  def eval({:q, n, m}, _) do
    zero_divisor_checker({:q, n, m})
    {:q, n, m}
  end
  def eval({:var, v}, env) do find_bind(env, {:var, v}) end
  def eval({:add, e0, e1}, env) do add(eval(e0, env), eval(e1, env)) end
  def eval({:sub, e0, e1}, env) do
    case eval(e1, env) do
      {:num, n}->add(eval(e0, env), {:num, -n})
      {:q, n, m}->sign_redundancy(add(eval(e0, env), {:q, -n, m}))
    end
  end
  def eval({:mul, e0, e1}, env) do mul(eval(e0, env), eval(e1, env)) end
  def eval({:div, e0, e1}, env) do divide(eval(e0, env), eval(e1, env)) end

  def add({:num, n0}, {:num, n1}) do {:num, n0 + n1} end
  def add({:q, n0, m}, {:num, n1}) do add({:q, n0, m}, {:q, n1 * m, m}) end
  def add({:num, n0}, {:q, n1, m}) do add({:q, n1, m}, {:num, n0}) end
  def add({:q, n0, m0}, {:q, n1, m1}) do
    {:q, n0, m0} = simplify_fraction({:q, n0, m0})
    {:q, n1, m1} = simplify_fraction({:q, n1, m1})
    l = lcm(m0, m1)
    {:q, n0, m0} = {:q, n0*(div(l, m0)), l}
    {:q, n1, m1} = {:q, n1*(div(l, m1)), l}
    (rem(n0 + n1, l) === 0 && {:num, div(n0 + n1, l)}) || {:q, n0 + n1, l}
  end

  def mul({:num, n0}, {:num, n1}) do {:num, n0 * n1} end
  def mul({:q, n0, m}, {:num, n1}) do
    {:q, n0, m} = simplify_fraction({:q, n0, m})
    div_one_redundancy(simplify_fraction({:q, n0 * n1, m}))
  end
  def mul({:num, n0}, {:q, n1, m}) do mul({:q, n1, m}, {:num, n0}) end
  def mul({:q, n0, m0}, {:q, n1, m1}) do
    {:q, n0, m0} = simplify_fraction({:q, n0, m0})
    {:q, n1, m1} = simplify_fraction({:q, n1, m1})
    div_one_redundancy(simplify_fraction({:q, n0 * n1, m0 * m1}))
  end

  def divide({:num, n0}, {:num, n1}) do
    zero_divisor_checker({:q, n0, n1})
    (rem(n0, n1) === 0 && {:num, div(n0, n1)}) || simplify_fraction({:q, n0, n1})
  end
  def divide({:q, n0, m}, {:num, n1}) do mul(simplify_fraction({:q, n0, m}), {:q, 1, n1}) end
  def divide({:num, n0}, {:q, n1, m}) do mul({:num, n0}, simplify_fraction({:q, m, n1})) end
  def divide({:q, n0, m0}, {:q, n1, m1}) do
    mul(simplify_fraction({:q, n0, m0}), simplify_fraction({:q, m1, n1}))
  end

  def sign_redundancy({:q, n, m}) when n < 0 and m < 0 do {:q, -n, -m} end
  def sign_redundancy(ex) do ex end

  def div_one_redundancy({:q, n, m}) when m === 1 do {:num, n} end
  def div_one_redundancy(ex) do ex end

  @spec zero_divisor_checker(value())::any()
  def zero_divisor_checker({:q, n, m}) when m === 0 do
    raise ArithmeticError, message: "Zero divisor detected in expression"
  end
  def zero_divisor_checker(_) do :ok end

  def simplify_fraction ({:q, n, m}) do
    g = gcd(n, m)
    {:q, div(n, g), div(m, g)}
  end
  def simplify_fraction(ex) do ex end

  @spec gcd(integer(), integer()) :: integer()
  def gcd(a, b) do
    r = rem(a, b)
    (r === 0 && b) || gcd(b, r)
  end

  @spec lcm(integer(), integer()) :: integer()
  def lcm(a, b) do div(a, gcd(a, b))*b end
end
