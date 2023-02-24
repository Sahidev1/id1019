defmodule Carlo do
  @type coordinate()::{:coord, integer(), integer()}

  def throw_dart(r) do
    {Enum.random(0..r), Enum.random(0..r)}
  end

  def round(_, 0, acc) do acc end
  def round(r, d_throws, acc) do
    add = throw_dart(r)|>in_quadrant(r)|>
    (fn bool -> (bool && 1)||0 end).()
    round(r, d_throws - 1, acc + add)
  end

  def rounds(nr_rounds, d_throws, r) do
    rounds(nr_rounds, d_throws, 0, r, 0, 1)
  end
  def rounds(nr_rounds, d_throws, r, t_factor) do
    rounds(nr_rounds, d_throws, 0, r, 0, t_factor)
  end
  defp rounds(0, _, tot, _, acc, t_factor) do
    IO.puts("done")
    est_pi(acc, tot)
  end
  defp rounds(nr_r, dt, tot, r, acc, t_factor) do
    acc = round(r, dt, acc)
    tot = tot + dt
    est_pi(acc, tot)|>(fn pi->
      :io.format("pi = ~14.7f, diff = ~14.7f\n", [pi, abs(pi - :math.pi())])
    end).()
    rounds(nr_r - 1, dt * t_factor, tot, r, acc, t_factor)
  end

  def est_pi(hits, tot_throws) do
    (4 * hits) / tot_throws
  end

  def in_quadrant({x, y}, r) do
    r_sqr = r*r
    x*x + y*y <= r_sqr
  end

  def perfect_round(r) do
    acc = perfect(r, 0, 0, 0)
  end
  defp perfect(r, curr_x, curr_y, acc) when curr_y > r do
    acc
  end
  defp perfect(r, curr_x, curr_y, acc) when curr_x > r do
    perfect(r, 0, curr_y + 1, acc)
  end
  defp perfect(r, curr_x, curr_y, acc) do
    add = in_quadrant({curr_x, curr_y}, r)|>
    (fn bool-> (bool && 1)||0 end).()
    perfect(r, curr_x + 1, curr_y, acc+add)
  end

  def conc_controlled_rounds(nr_r, dt, r, nr_subtasks, fpid) do
    sleep_ms = 100
    conc_rounds(nr_r, dt, r, nr_subtasks, fpid) && conc_controller(nr_subtasks, sleep_ms)
  end

  def conc_controller(nr_subtasks, sleep_ms) do
    looper(nr_subtasks, sleep_ms, [])
  end

  defp looper(nr_subtasks, sleep_ms, msg_q) do
    cond do
      length(msg_q) === nr_subtasks->
        avg = Enum.reduce(msg_q, 0, fn {_,_, res},acc -> res + acc end) / nr_subtasks
        {:result, {:avg, avg}, {:runs, msg_q}}
      true->
        receive do
          {:done, {s, c, r}} ->
          msg_q = [{s, c, r}|msg_q]
          :timer.sleep(sleep_ms)
          looper(nr_subtasks, sleep_ms, msg_q)
        end
      end
  end

  def conc_rounds(nr_r, dt, r, nr_subtasks, fpid) do
    d = div(nr_r, nr_subtasks)
    rema = rem(nr_r, nr_subtasks)
    start_task(d + rema, dt, r, fpid)
    conc_proc(nr_r - (d + rema), dt, r, d, fpid)
  end
  defp conc_proc(nr_r, dt, r, d, fpid) when nr_r <= 0 do :ok end
  defp conc_proc(nr_r, dt, r, d, fpid) do
    start_task(d, dt, r, fpid)
    conc_proc(nr_r - d, dt, r, d, fpid)
  end

  def start_task(nr_rounds, dt, r, fpid) do
    Task.start_link(fn ->
      start_t = mono_time()
      res = rounds(nr_rounds, dt, r)
      complete_t = abs(mono_time() - start_t)
      send(fpid, {:done,{start_t, complete_t, res}})
    end)
  end

  def mono_time() do
    System.monotonic_time()|>System.convert_time_unit(:native, :millisecond)
  end
end
