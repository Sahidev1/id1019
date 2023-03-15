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

    def genmap() do morse()|>to_map('',%{}) end

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

    #encoder
    def encode(msg) do
      table = genmap();
      encode(msg, table, '')
    end
    #tail recursive implementation
    def encode([], table, encoding) do encoding end
    def encode([charval|msg], table, encoding) do
      encoding = encoding++Map.get(table, charval)
      encode(msg, table, encoding)
    end
end
