
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

  @spec simplify(expr()) :: expr()
  def simplify({:add, {:num, 0}, ex}) do ex end
  def simplify({:add, ex, {:num, 0}}) do ex end

  def simplify({:add, {:num, c0}, {:num, c1}}) do {:num, c0 + c1} end

  def simplify({:mul, {:num, 1}, ex}) do ex end
  def simplify({:mul, ex, {:num, 1}}) do ex end

  def simplify({:mul, {:num, c0}, {:num, c1}}) do {:num, c0 * c1} end
  def simplify({:mul, _, {:num, 0}}) do {:num, 0} end
  def simplify({:mul, {:num, 0}, _}) do {:num, 0} end
  def simplify(_) do false end

  @spec outer_simplify(expr()):: expr()
  def outer_simplify(ex) do
    simplex = simplify(ex)
    if simplex === false do
      ex
    else
      outer_simplify(simplex)
    end
  end

  @spec inner_simplify(expr()) :: expr()
  def inner_simplify(ex) do
    IO.inspect(ex)
    IO.puts("\n")
    case ex do
      {:num,_}-> ex
      {:var,_}-> ex
      {:mul, ex0, ex1} ->
        isim0 = inner_simplify(ex0);
        isim1 = inner_simplify(ex1);
        IO.inspect(simplify({:mul, isim0, isim1})||ex)
        IO.puts("\nsimple")
        simplify({:mul, isim0, isim1})||ex #sim0 can be false if ex0 cannot be further simplified
      {:add, ex0, ex1} ->
        isim0 = inner_simplify(ex0);
        isim1 = inner_simplify(ex1);
        IO.inspect(simplify({:add, isim0, isim1})||ex)
        IO.puts("\nsimple")
        simplify({:add, isim0, isim1})||ex
      _-> ex #throw error?
    end
  end
end
