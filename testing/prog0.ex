defmodule Prog0 do
  @type component() :: {:num, number()} | {:var, atom()}

  @spec nondiscfun(component()) :: binary()

  @spec fun(component()) :: boolean()
  def fun(comp) do
    {comptype, _} = comp
    case comptype do
      :num -> IO.puts("number")
      :var -> IO.puts("variable")
      _-> IO.puts("neither")
    end
  end

  def test() do
    c0 = {:num, 223}
    c1 = {:var, :x}
    c2 = {:thing, "hello"}
    table = [c0, c1, c2];
    testproc(table)
  end

  defp testproc(list) do
    if length(list) === 0 do
      "empty list"
    else
      [h|t] = list
      fun(h)
      testproc(t)
    end
  end

  def nondiscfun ({:num, n}) do
    {_, b} = {:num, n};
    IO.puts("nmr")
    IO.puts(b)
  end

  def nondiscfun ({:var, _}) do
    IO.puts("var")
  end

end
