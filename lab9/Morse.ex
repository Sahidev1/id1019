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
      map = to_map(short, path++'.', map)
      map
    end
    def to_map({_, char, long, short}, path, map) do
      map = Map.put(map, char, path)
      map = to_map(long, path++'-', map)
      map = to_map(short, path++'.', map)
      map
    end


    def gen_decode_list() do morse()|>to_list('',[]) end

    def to_list(nil, path, lst) do lst end
    def to_list({_, :na, long, short}, path, lst) do
      lst = to_list(long, path++'-', lst)
      lst = to_list(short, path++'.', lst)
      lst
    end
    def to_list({_, char, long, short}, path, lst) do
      lst = to_list(long, path++'-', lst)
      lst = to_list(short, path++'.', lst)
      [{path, char}|lst]
    end

    #encoder
    def encode(msg) do
      table = gen_encode_map()
      encode(msg, table, '')
    end
    #tail recursive implementation
    def encode([], table, encoding) do encoding end
    def encode([charval|msg], table, encoding) do
      encoding = encoding++' '++Map.get(table, charval)
      encode(msg, table, encoding)
    end


    def decoder(code) do
      tree = morse()
      decoder(tree, code, '', '')
    end
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

    def decode(tree={_, char, _, _}, []) do [char] end
    def decode(tree={_, char, long, short}, code=[c|rest]) do
      case [c] do
        '-'->decode(long, rest)
        '.'->decode(short, rest)
      end
    end
end
