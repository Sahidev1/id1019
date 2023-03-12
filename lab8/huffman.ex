
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
    sample = sample()
    [tree|_] = tree(sample)
    encode = encode_table(tree)
    decode = decode_table(tree)
    text = text()
    seq = encode(text, encode)
    decode(seq, decode)
  end

  def test2(input) do
    [tree|_] = tree(input)
    tab = encode_table(tree)
    IO.inspect((fn l-> Enum.map(l, fn {c,path}-> {[c], path} end) end).(tab))
    enc = encode(input, tab)
    IO.inspect(enc)
    decoder = decode_table(tree)
    IO.inspect(decoder)
    decode(enc, decoder)
  end

  def tree(sample) do
    prio_q = freq(sample)
    huffman(prio_q)
  end

  def huffman([{e, v}|[]]) do [{e, v}] end
  def huffman([h0={e0, v0}|[h1={e1, v1}|t]]) do
    putnode(t, {{h0, h1}, v0 + v1})|>huffman()
  end

  def putnode([], n) do [n] end
  def putnode(tree=[{_, v0}|_], n={_, v1}) when v1 <= v0 do [n|tree] end
  def putnode([h|t], n) do [h|putnode(t, n)] end

  def encode_table({{left, right}, v}) do
    left_c = encode_table(left)
    right_c = encode_table(right)
    add_path(left_c, 0)++add_path(right_c, 1)
  end
  def encode_table({char, v}) do [{char, []}] end
  def add_path([], v) do [] end
  def add_path([{char, path}|rest], v) do
    [{char, [v|path]}|add_path(rest, v)]
  end

  def decode_table(tree) do
    encode_table(tree)|>Enum.map(fn {char, code}-> {code, char} end)
  end

  def encode(text, table) do encode(text, table, table) end
  def encode([], _, _) do [] end
  def encode([char|rest], [{char, path}|_], init) do path++encode(rest, init) end
  def encode(txt=[char0|rest], table=[{char1, path}|st], init) do
    encode(txt, st, init)
  end

  def decode([], _) do [] end
  def decode(seq, table) do
    {char, rest} = decode_char(seq, 1, table)
    [char|decode(rest, table)]
  end
  def decode_char(seq, n, table) do
    {code, rest} = Enum.split(seq, n)
    case List.keyfind(table, code, 0) do
      {_, char}->{char, rest}
      nil->decode_char(seq, n + 1, table)
    end
  end

  def freq(char_list) do
    freq(char_list, [])|>Enum.sort(fn {_, c0}, {_, c1}-> c0 < c1 end)
  end
  def freq([], f) do f end
  def freq([h|t], f) do
    f = put(h, f)
    freq(t, f)
  end
  def put(char, []) do [{char, 1}] end
  def put(char, [{char, count}|t]) do [{char, count + 1}|t] end
  def put(char, [h|t]) do [h|put(char, t)] end
end
