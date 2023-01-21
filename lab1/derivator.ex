
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

  @spec derive(expr(), atom()) :: expr()
  #implement with var set to specific atom such as :v, :x, :y etc

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

  def derive({:ln, {:num, _}}, _) do {:num, 0} end
  def derive({:ln, {:var, v}}, v) do  {:pow, {:var, v}, {:num, -1}} end
  def derive({:ln, {:var, _}}, _) do {:num, 0} end # var is a constant like pi
  def derive({:ln, ex}, v) do chain_rule({:ln, ex}, v) end

  def derive({:sin, {:num, _}}, _) do {:num, 0} end
  def derive({:sin, {:var, v}}, v) do {:cos, {:var, v}} end
  def derive({:sin, {:var, _}}, _) do {:num, 0} end
  def derive({:sin, ex}, v) do chain_rule({:sin, ex}, v) end

  def derive({:cos, {:num, _}}, _) do {:num, 0} end
  def derive({:cos, {:var, v}}, v) do
    {:mul, {:num, -1}, {:sin, {:var, v}}}
  end
  def derive({:cos, {:var, _}}, _) do {:num, 0} end
  def derive({:cos, ex}, v) do chain_rule({:cos, ex}, v) end


  # implementing chain rule with ex0 as inner function
  @spec chain_rule(expr(), atom()) :: expr()
  def chain_rule({op, ex0, ex1}, v) do
    atomex0 = {op, {:var, :atex}, ex1}
    d_atomex0 = derive(atomex0, :atex)
    outer_deriv = replace_atom_toexp(d_atomex0, :atex, ex0);
    inner_deriv = derive(ex0, v);
    {:mul, inner_deriv, outer_deriv}
  end

  def chain_rule({op, ex}, v) do
    atomex = {op, {:var, :atex}}
    d_atomex = derive(atomex, :atex)
    outer_deriv = replace_atom_toexp(d_atomex, :atex, ex)
    inner_deriv = derive(ex, v)
    {:mul, inner_deriv, outer_deriv}
  end

  @spec simplify(expr()) :: expr()
  def simplify({:add, {:num, 0}, ex}) do ex end
  def simplify({:add, ex, {:num, 0}}) do ex end

  def simplify({:add, {:num, c0}, {:num, c1}}) do {:num, c0 + c1} end

  def simplify({:mul, {:num, 1}, ex}) do ex end
  def simplify({:mul, ex, {:num, 1}}) do ex end

  def simplify({:mul, {:num, c0}, {:num, c1}}) do {:num, c0 * c1} end
  def simplify({:mul, _, {:num, 0}}) do {:num, 0} end
  def simplify({:mul, {:num, 0}, _}) do {:num, 0} end
  def simplify(ex) do ex end

  @spec simplifier(expr()) :: expr()
  def simplifier(ex) do
    case ex do
      {optype, ex0, ex1}->
        s0 = simplifier(ex0)
        s1 = simplifier(ex1)
        simplify({optype, s0, s1})
      _-> ex
    end
  end

  @spec replace_atom_toexp(expr(),atom(),expr()) :: expr()
  def replace_atom_toexp(root, replace_atom, replacer) do
    case root do
      {_, ^replace_atom}->
        replacer
      {op, ex0, ex1}->
        f0 = replace_atom_toexp(ex0, replace_atom, replacer)
        f1 = replace_atom_toexp(ex1, replace_atom, replacer)
        {op, f0||ex0, f1||ex1}
      {op, ex}->
        f = replace_atom_toexp(ex, replace_atom, replacer)
        {op, f||ex}
      _-> nil
    end
  end
end
