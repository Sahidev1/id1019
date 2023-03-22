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

      rolled=   '.... - - .--. ... ---... .----- .----- .-- .-- .-- .-.-.- -.-- --- ..- - ..- -... . .-.-.- -.-. --- -- .----- .-- .- - -.-. .... ..--.. ...- .----. -.. .--.-- ..... .---- .-- ....- .-- ----. .--.-- ..... --... --. .--.-- ..... ---.. -.-. .--.-- ..... .---- '

      name = 'ali'

      enc = encode(name)
      IO.puts(enc)
      dec = decoder(enc)
      IO.puts(dec)

      IO.puts(decoder(base))
      IO.puts(decoder(rolled))
    end

    #to morse using the initial tree
    def to_morse(nil, char1, path) do nil end
    def to_morse({_, char, long, short}, char, path) do path end
    def to_morse({_, char0, long, short}, char1, path) do
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
    def to_map(nil, path, map) do map end
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
      encode(msg, table, '')
    end
    #tail recursive implementation
    def encode([], table, encoding) do encoding end
    #function complexity: C = 0 + 1 + 2² + 3² +...+ (m - 1)² + m² =   O(n²) since telescoping series: sigma(m² - (m-1)²)[0,n] = n²
    def encode([charval|msg], table, encoding) do
      encoding = encoding++' '++Map.get(table, charval)# operation complexity: copying encoding and going to the end of encoding list, if encoding size is n => O(m²)
      encode(msg, table, encoding)
    end



    def decoder(code) do
      tree = morse()
      decoder(tree, code, '', '')
    end
    # For each space seperated morsecode in the morsecode message sequence we do:
    # we append all the morse characters between the spaces, For a morsecode of length l
    # the number of ops can be described 1 + 2 + ... + (l - 1) + l = l²/2 => Complexity is O(l²).
    # After we have appended all characters between the spaces we have the full morsecode and lookup the character associated with it
    # and then we append the character to the decoded msg so far. For a morsecode sequence of length m morsecodes we will perform
    # (L²) + 2(L²) + ... (m - 1)L² + mL² = m²L²/4. In out case l has a max value of 6 since max depth of morse tree is 6.
    # Each lookup also has at most complexity 6 in our case and we can consider the lookup operation constant.
    # Therefor for large m we can consider l to be a constant => Complexity of O(m²) where m is the number of morsecodes in the morse sequence.
    # If L is the average length of each morse code then total number of character in the morse sequence can be defined as v = L*m => Complexity in
    # terms of the number of characters in the morse sequence: complexity O(v²).
    def decoder(_, [], [], msg) do msg end
    def decoder(tree, [], curr, msg) do msg++decode(tree, curr) end
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
    def decode(tree={_, char, _, _}, []) do [char] end
    def decode(tree={_, char, long, short}, code=[c|rest]) do
      case [c] do
        '-'->decode(long, rest)
        '.'->decode(short, rest)
      end
    end
end
