
# x²
{:mul, {:var, :x}, {:var, :x}}

# 2x² + 3x + 5
{:add, {:add, {:mul, {:num, 2}, {:mul, {:var, :x}, {:var, :x}}}, {:mul, {:num, 3}, {:var, :x}}}, {:num, 5}}

# (2 + 0) + 0
{:add, {:add, {:num, 2}, {:num, 0}}, {:num, 0}}

# 1 + sin(2x+1)
{:add, {:var, :x}, {:sin, {:add, {:mul, {:num, 2}, {:var, :x}}, {:num, 1}}}}

# (ln(2 + x) * x²) + 3x
{:add,
 {:mul, {:ln, {:add, {:var, :x}, {:num, 2}}}, {:pow, {:var, :x}, {:num, 2}}},
 {:mul, {:var, :x}, {:num, 3}}}

# x³ + 2x² + 5
{:add,
 {:add, {:pow, {:var, :x}, {:num, 3}},
  {:mul, {:num, 2}, {:pow, {:var, :x}, {:num, 2}}}}, {:num, 5}}
