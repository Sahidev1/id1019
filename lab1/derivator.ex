
defmodule Derivator do
  @type literal :: {:num, number()}
  | {:var, atom()}

  @type expr :: {:add, expr(), expr()}
  | {:mul, expr(), expr()}
  | {:pow, expr(), literal()}
  | {:ln, expr()}
  | {:sin, expr()}
  | {:cos, expr()}
  | literal()

  @spec testrun() :: expr()
  def testrun do
    # sample: x³ + 2x² + 5
    sample = {:add,
    {:add, {:pow, {:var, :x}, {:num, 3}},
    {:mul, {:num, 2}, {:pow, {:var, :x}, {:num, 2}}}}, {:num, 5}}
    d_sample = derive(sample, :x)
    final_result = simplifier(d_sample)
    IO.puts("function: #{pprint(sample)}")
    IO.puts("derivative #{pprint(d_sample)}")
    IO.puts("simplified derivative: #{pprint(final_result)}")
  end

  @spec derive(expr(), atom()) :: expr()
  def derive({:num, _}, _) do {:num, 0} end
  def derive({:var, v}, v) do {:num, 1} end
  def derive({:var, _}, _) do {:num, 0} end #Constant
  def derive({:add, ex0, ex1}, v) do {:add, derive(ex0, v), derive(ex1, v)} end

  def derive({:mul, ex0, ex1}, v) do
    d_ex0 = derive(ex0, v)
    d_ex1 = derive(ex1, v)
    {:add, {:mul, ex0, d_ex1}, {:mul, ex1, d_ex0}}
  end

  def derive({:pow, {:num, _}, _}, _) do {:num, 0} end
  def derive({:pow, _, {:num, 0}}, _) do {:num, 1} end # e.g. x^0

  def derive({:pow, {:var, v}, {:num, n}}, v) do
    variable = {:pow, {:var, v}, {:num, n - 1}}
    coeff = {:num, n}
    {:mul, coeff, variable}
  end

  def derive({:pow, {:var, v}, {:var, c}}, v) do
    variable = {:pow, {:var, v}, {:add, {:var, c}, {:num, -1}}}
    coeff = {:var, c}
    {:mul, coeff, variable}
  end

  def derive({:pow, {op, ex0, ex1}, l}, v) do
    chain_rule({:pow, {op, ex0, ex1}, l}, v)
  end

  def derive({:pow, {:var, _}, _}, _) do {:num, 0} end # var is constant

  def derive({:pow, {op, ex}, l}, v) do
    chain_rule({:pow, {op, ex}, l}, v)
  end

  def derive({:ln, {:var, v}}, v) do  {:pow, {:var, v}, {:num, -1}} end
  def derive({:sin, {:var, v}}, v) do {:cos, {:var, v}} end
  def derive({:cos, {:var, v}}, v) do {:mul, {:num, -1}, {:sin, {:var, v}}} end
  def derive({_, {:num, _}}, _) do {:num, 0} end
  def derive({_, {:var, _}}, _) do {:num, 0} end
  def derive({:cos, ex}, v) do chain_rule({:cos, ex}, v) end
  def derive({:sin, ex}, v) do chain_rule({:sin, ex}, v) end
  def derive({:ln, ex}, v) do chain_rule({:ln, ex}, v) end

  # implementing chain rule with ex0 as inner function
  # replaces inner expression with an atom and derives the expression
  # then replace the atom in the derivative with the original inner expression
  # then we evualute derivate of inner expression
  @spec chain_rule(expr(), atom()) :: expr()
  def chain_rule({op, ex0, ex1}, v) do
    atomex0 = {op, {:var, :atex}, ex1}
    d_atomex0 = derive(atomex0, :atex)
    outer_deriv = replace_atom_with_expr(d_atomex0, :atex, ex0)
    inner_deriv = derive(ex0, v)
    {:mul, inner_deriv, outer_deriv}
  end

  def chain_rule({op, ex}, v) do
    atomex = {op, {:var, :atex}}
    d_atomex = derive(atomex, :atex)
    outer_deriv = replace_atom_with_expr(d_atomex, :atex, ex)
    inner_deriv = derive(ex, v)
    {:mul, inner_deriv, outer_deriv}
  end

  # this function provides matches for simplifying expressions
  @spec simplify(expr()) :: expr()
  def simplify({:add, {:num, 0}, ex}) do ex end
  def simplify({:add, ex, {:num, 0}}) do ex end

  def simplify({:add, {:num, c0}, {:num, c1}}) do {:num, c0 + c1} end
  def simplify({:add, {:var, v}, {:var, v}}) do
    {:mul, {:num, 2}, {:var, v}}
  end
  def simplify({:add, {:add, ex, {:num, c0}}, {:add, ex, {:num, c1}}}) do
    {:add, {:mul, {:num, 2}, ex}, {:num, c0 + c1}}
  end
  def simplify({:add, {:add, ex0, {:num, c0}}, {:add, ex1, {:num, c1}}}) do
    {:add, {:add, ex0, ex1}, {:num, c0 + c1}}
  end

  def simplify({op, {:num, c0}, {op, {:num, c1}, ex}}) do
    case op do
      :mul->{op, {:num, c0 * c1}, ex}
      :add->{op, {:num, c0 + c1}, ex}
    end
  end
  def simplify({op, {op, {:num, c1}, ex}, {:num, c0}}) do
    simplify({op, {:num, c0}, {op, {:num, c1}, ex}})
  end
  def simplify({op, {op, ex, {:num, c1}}, {:num, c0}}) do
    simplify({op, {:num, c0}, {op, {:num, c1}, ex}})
  end
  def simplify({op, {:num, c0}, {op, ex, {:num, c1}}}) do
    simplify({op, {:num, c0}, {op, {:num, c1}, ex}})
  end

  def simplify({:mul, {:num, 1}, ex}) do ex end
  def simplify({:mul, ex, {:num, 1}}) do ex end

  def simplify({:mul, {:num, c0}, {:num, c1}}) do {:num, c0 * c1} end
  def simplify({:mul, _, {:num, 0}}) do {:num, 0} end
  def simplify({:mul, {:num, 0}, _}) do {:num, 0} end

  def simplify({:pow, ex, {:num, 1}}) do ex end
  def simplify({:pow, _, {:num, 0}}) do {:num, 1} end
  def simplify({:pow, {:num, n0}, {:num, n1}}) do {:num, :math.pow(n0,n1)} end

  def simplify({:ln, {:num, 1}}) do {:num, 0} end
  def simplify({:ln, {:num, c}}) do
    if (c > 0) do
      {:num, :math.log(c)}
    else
      {:err, "undefined"}
    end
  end
  def simplify({:sin, {:num, c}}) do {:num, :math.sin(c)} end
  def simplify({:cos, {:num, c}}) do {:num, :math.cos(c)} end

  def simplify(ex) do ex end # return expression when no simplification found or expr is atomic

  # function traverses AST to its atomic leaves and then propagates back to root
  # while propagating through each non-atomic node it simplifies the
  # expression of each nodes subtree
  @spec simplifier(expr()) :: expr()
  def simplifier(ex) do
    case ex do
      {optype, ex0, ex1}->
        s0 = simplifier(ex0)
        s1 = simplifier(ex1)
        simplify({optype, s0, s1})
      {optype, ex}->
        s = simplifier(ex)
        simplify({optype, s})
      _-> ex
    end
  end

  # function that replaces an atomic leaf in an expression
  # with another expression
  # function traverses AST until a matching atom is found
  # and replaces it with the replacement expression
  @spec replace_atom_with_expr(expr(),atom(),expr()) :: expr()
  def replace_atom_with_expr(root, replace_atom, replacer) do
    case root do
      {_, ^replace_atom}->
        replacer
      {op, ex0, ex1}->
        f0 = replace_atom_with_expr(ex0, replace_atom, replacer)
        f1 = replace_atom_with_expr(ex1, replace_atom, replacer)
        {op, f0||ex0, f1||ex1}
      {op, ex}->
        f = replace_atom_with_expr(ex, replace_atom, replacer)
        {op, f||ex}
      _-> nil
    end
  end

  @spec pprint(expr()) :: binary()
  def pprint({:var, v}) do "#{v}" end
  def pprint({:num, n}) do "#{n}" end
  def pprint({:add, ex0, ex1}) do "(#{pprint(ex0)} + #{pprint(ex1)})" end
  def pprint({:mul, ex0, ex1}) do "(#{pprint(ex0)} * #{pprint(ex1)})" end
  def pprint({:pow, ex, l}) do "(#{pprint(ex)}^#{pprint(l)})" end
  def pprint({op, ex}) do "(#{op}(#{pprint(ex)}))" end
end
