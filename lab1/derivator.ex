
defmodule Derivator do

  @type literal :: {:num, number()}
  | {:var, atom()}

  @type expr :: {:add, expr(), expr()}
  | {:mul, expr(), expr()}
  | {:pow, expr(), literal()}
  | literal()

  @spec derive(expr(), atom()) :: expr()
  #implement with var set to specific atom such as :v, :x, :y etc

  def derive({:num, _}, _) do {:num, 0} end
  def derive({:var, v}, v) do {:num, 1} end
  def derive({:var, _}, _) do {:num, 0} end #Constant
  def derive({:add, ex0, ex1}, v) do
    {:add, derive(ex0, v), derive(ex1, v)}
  end
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
    atomex = {:pow, {:var, :atex}, l}
    d_atomex = derive(atomex, :atex);
    outer_der = replace_atom_toexp(d_atomex, :atex, {op, ex0, ex1})
    inner_der = derive({op, ex0, ex1}, v);
    {:mul, inner_der, outer_der}
  end

  def derive({:pow, {:var, _}, _}, _) do {:num, 0} end # var is constant
  # implementing chain rule

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
      _-> nil
    end
  end
end
