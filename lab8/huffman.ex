
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

  def huffman(tree) when length(tree) === 1 do tree end
  def huffman(tree) do
    {tree, h0={e0, min0}} = getmin(tree)
    {tree, h1={e1, min1}} = getmin(tree)

    tree = [{{h0, h1}, min0 + min1}|tree]
    #IO.inspect(tree)
    huffman(tree)
  end

  def getmin([]) do {[], -1} end
  def getmin(prio_q=[e|t]) do getmin(prio_q, e) end
  def getmin([], m) do {[], m} end
  def getmin([e={huff, c0}|q], m={_,c1}) when c0 < c1 do
    {upd_q, min}=getmin(q, e)
    case min do
      ^e->
        {upd_q, min}
      _->
        {[e|upd_q], min}
    end
  end
  def getmin([e|q], m) do
    {upd_q, min} = getmin(q, m)
    case min do
      ^e->
        {upd_q, min}
      _->
        {[e|upd_q], min}
    end
  end

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

  def freq(char_list) do freq(char_list, []) end
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
