
# x²
{:mul, {:var, :x}, {:var, :x}}

# 2x² + 3x + 5
{:add, {:add, {:mul, {:num, 2}, {:mul, {:var, :x}, {:var, :x}}}, {:mul, {:num, 3}, {:var, :x}}}, {:num, 5}}

# (2 + 0) + 0
{:add, {:add, {:num, 2}, {:num, 0}}, {:num, 0}}
