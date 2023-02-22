defmodule Carlo do
  @type coordinate()::{:coord, integer(), integer()}

  def throw_dart(r) do
    {:coord, Enum.random(0..r), Enum.random(0..r)}
  end

  def round(_, 0, acc) do acc end
  def round(r, d_throws, acc) do
    add = throw_dart(r)|>in_quadrant(r)|>
    (fn bool -> (bool && 1)||0 end).()
    round(r, d_throws - 1, acc + add)
  end

  def rounds(nr_rounds, d_throws, r) do
    rounds(nr_rounds, d_throws, 0, r, 0)
  end
  def rounds(0, _, tot, _, acc) do
    est_pi(acc, tot)
  end
  def rounds(nr_r, dt, tot, r, acc) do
    acc = round(r, dt, acc)
    tot = tot + dt
    est_pi(acc, tot)|>(fn pi->
      :io.format("pi = ~14.6f, diff = ~14.6f\n", [pi, abs(pi - :math.pi())])
    end).()
    rounds(nr_r - 1, dt, tot, r, acc)
  end

  def est_pi(hits, tot_throws) do
    (4 * hits) / tot_throws
  end

  def in_quadrant({:coord, x, y}, r) do
    r_sqr = r*r
    x*x + y*y <= r_sqr
  end

end
