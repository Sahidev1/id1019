
defmodule Huffman do
  @type huff()::{{huff(), huff()}, integer()}
  | {char(), integer()}

  def sample do
    'the quick brown fox jumps over the lazy dog
    this is a sample text that we will use when we build
    up a table we will only handle lower case letters and
    no punctuation symbols the frequency will of course not
    represent english but it is probably not that far off'
  end

  def text() do
    'this is something that we should encode'
  end

  def test do
    sample = text()
    tree = tree(sample)
    #encode = encode_table(tree)
    #decode = decode_table(tree)
    #text = text()
    #seq = encode(text, encode)
    #decode(seq, decode)
  end

  def tree(sample) do
    prio_q = freq(sample)
    huffman(prio_q)
  end

  def huffman([{e, v}|[]]) do [{e, v}] end
  def huffman([h0={e0, v0}|[h1={e1, v1}|t]]) do
    #node = {{h0, h1}, v0 + v1}

    IO.inspect({h0,h1})
    tree = putnode(t, {{h0, h1}, v0 + v1})
    IO.inspect(tree)
    huffman(tree)
  end

  def putnode([], n) do [n] end
  def putnode(tree=[{_, v0}|_], n={_, v1}) when v1 <= v0 do [n|tree] end
  def putnode([h|t], n) do [h|putnode(t, n)] end

  def encode_table(tree) do
    # To implement...
  end

  def decode_table(tree) do
    # To implement...
  end

  def encode(text, table) do
    # To implement...
  end

  def decode(seq, tree) do
    # To implement...
  end

  def freq(char_list) do
    freq(char_list, [])|>Enum.sort(fn {_, c0}, {_, c1}-> c0 < c1 end)
  end
  def freq([], f) do f end
  def freq([h|t], f) do
    f = put(h, f)
    upd_f = freq(t, f)
    upd_f
  end
  def put(char, []) do [{char, 1}] end
  def put(char, [{char, count}|t]) do [{char, count + 1}|t] end
  def put(char, [h|t]) do [h|put(char, t)] end
end
