
#function that returns the last element in a list
defmodule Prog do
  def lastElem(list) do
    if length(list) === 1 do
      [ret] = list
      ret
    else
      [_ | t] = list
      lastElem(t)
    end
  end
end
