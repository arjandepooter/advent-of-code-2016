input =
  IO.read(:stdio, :all)
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(fn s -> s |> String.split("-") |> Enum.map(&String.to_integer/1) end)
  |> Enum.map(fn [a, b | _] -> {a, b} end)
  |> Enum.sort()

input
|> List.foldl(0, fn {start, stop}, n ->
  if n >= start && n <= stop do
    stop + 1
  else
    n
  end
end)
|> IO.puts()

input
|> List.foldl({0, Integer.pow(2, 32)}, fn {start, stop}, {cur, result} ->
  case {cur >= start, cur <= stop} do
    {true, true} -> {stop + 1, result - (stop - cur + 1)}
    {false, true} -> {stop + 1, result - (stop - start + 1)}
    _ -> {cur, result}
  end
end)
|> elem(1)
|> IO.puts()
