
defmodule Derivator do

  @type literal :: {:num, number()}
  | {:var, atom()}

  @type expr :: {:add, expr(), expr()}
  | {:mul, expr(), expr()}
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

  @spec outer_scope_simplify(expr()) :: expr()
  def outer_scope_simplify({:add, {:num, 0}, ex}) do ex end
  def outer_scope_simplify({:add, ex,{:num, 0}}) do ex end
  def outer_scope_simplify({:mul, {:num, 1}, ex}) do ex end
  def outer_scope_simplify({:mul, ex, {:num, 1}}) do ex end
  def outer_scope_simplify(_) do false end

  @spec simplify(expr()):: expr()
  def simplify (ex) do
    simplex = outer_scope_simplify(ex)
    if simplex === false do
      ex
    else
      simplify(simplex)
    end
  end
end
