defmodule Morse do
  def morse() do
    {:node, :na,
    {:node, 116,
    {:node, 109,
    {:node, 111,
    {:node, :na, {:node, 48, nil, nil}, {:node, 57, nil, nil}},
    {:node, :na, nil, {:node, 56, nil, {:node, 58, nil, nil}}}},
    {:node, 103,
    {:node, 113, nil, nil},
    {:node, 122,
    {:node, :na, {:node, 44, nil, nil}, nil},
    {:node, 55, nil, nil}}}},
    {:node, 110,
    {:node, 107, {:node, 121, nil, nil}, {:node, 99, nil, nil}},
    {:node, 100,
    {:node, 120, nil, nil},
    {:node, 98, nil, {:node, 54, {:node, 45, nil, nil}, nil}}}}},
    {:node, 101,
    {:node, 97,
    {:node, 119,
    {:node, 106,
    {:node, 49, {:node, 47, nil, nil}, {:node, 61, nil, nil}},
    nil},
    {:node, 112,
    {:node, :na, {:node, 37, nil, nil}, {:node, 64, nil, nil}},
    nil}},
    {:node, 114,
    {:node, :na, nil, {:node, :na, {:node, 46, nil, nil}, nil}},
    {:node, 108, nil, nil}}},
    {:node, 105,
    {:node, 117,
    {:node, 32,
    {:node, 50, nil, nil},
    {:node, :na, nil, {:node, 63, nil, nil}}},
    {:node, 102, nil, nil}},
    {:node, 115,
    {:node, 118, {:node, 51, nil, nil}, nil},
    {:node, 104, {:node, 52, nil, nil}, {:node, 53, nil, nil}}}}}}
    end

    def test() do

      base =  '.- .-.. .-.. ..-- -.-- --- ..- .-. ..-- -... .- ... . ..-- .- .-. . ..-- -... . .-.. --- -. --. ..-- - --- ..-- ..- ... '

      rolled =   '.... - - .--. ... ---... .----- .----- .-- .-- .-- .-.-.- -.-- --- ..- - ..- -... . .-.-.- -.-. --- -- .----- .-- .- - -.-. .... ..--.. ...- .----. -.. .--.-- ..... .---- .-- ....- .-- ----. .--.-- ..... --... --. .--.-- ..... ---.. -.-. .--.-- ..... .---- '

      name = 'ali'

      enc = encode(name)
      IO.puts(enc)
      dec = decoder(enc)
      IO.puts(dec)

      IO.puts(decoder(base))
      IO.puts(decoder(rolled))
    end

    #to morse using the initial tree
    def to_morse(nil, _, _) do nil end
    def to_morse({_, char, _,_}, char, path) do path end
    def to_morse({_, _, long, short}, char1, path) do
      lres = to_morse(long, char1, path++'-')
      sres = to_morse(short, char1, path++'.')
      if lres !== nil do
        lres
      else
        sres
      end
    end

    def gen_encode_map() do morse()|>to_map('',%{}) end

    #tree to map
    def to_map(nil, _, map) do map end
    def to_map({_, :na, long, short}, path, map) do
      map = to_map(long, path++'-', map)
      to_map(short, path++'.', map)    end
    def to_map({_, char, long, short}, path, map) do
      map = Map.put(map, char, path)
      map = to_map(long, path++'-', map)
      to_map(short, path++'.', map)
    end

    #encoder
    def encode(msg) do
      table = gen_encode_map()
      Enum.reverse(msg)|>encode(table, '')
    end
    #tail recursive implementation
    #function complexity: Reverse a list of size n take n ops.
    #encoding up after reversing will have this ops: m0 + 2m1 + 3m2 +... + (n-1)mk + n*mk+1 => if M is avg length of all morse => M*n operations in total => O(M*n)
    # nr ops including reversal: C = M*n + n. Since M*n will dominate or equal n for different values of M and n => Final complexity: O(M*n)
    def encode([], _, encoding) do encoding end
    #function complexity:
    def encode([charval|msg], table, encoding) do
      encode(msg, table, Map.get(table, charval)++[32|encoding]) # Append operation complexity O(m) where m is the length of looked up morsecode.
    end


    def decoder(code) do
      tree = morse()
      decoder(tree, code, '', '')
    end

    def decoder(_, [], [], msg) do msg end
    def decoder(tree, [], curr, msg) do
      msg++decode(tree, curr) end
    def decoder(tree, [32|code], [], msg) do
      decoder(tree, code, [], msg)
    end
    def decoder(tree, [32|code], curr, msg) do
      msg = msg++decode(tree, curr)
      decoder(tree, code, [], msg)
    end
    def decoder(tree, [char|code], curr, msg) do
      decoder(tree, code, curr++[char], msg)
    end

    # Function complexity: Since we are using the morse tree for decoding
    # the complexity of decoding a morsecode is equivalent to the length of the morsecode.
    # The characters of the morse code is essentialy direction to the character on the tree.
    # The complexity can be described as O(v) where v = |morsecode|
    # The best case complexity is O(1) and the worst case complexity is O(w) where w is the depth of the morse tree
    def decode({_, char, _, _}, []) do [char] end
    def decode({_, _, long, short}, [c|rest]) do
      case [c] do
        '-'->decode(long, rest)
        '.'->decode(short, rest)
      end
    end
end
