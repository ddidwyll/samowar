defmodule De do
  def bug_full(data, title \\ "Debug"), do: log(data, :full, title)
  def bug(data, title \\ "Debug"), do: log(data, !:full, title)
  def file(data, to_file, title \\ "Debug"), do: log(data, :full, title, to_file)

  def bug_in(data, keys, title \\ "Debug") do
    data
    |> get_in(List.wrap(keys))
    |> log(!:full, title)

    data
  end

  defp log(data, full?, title, to_file \\ nil) do
    device = device(to_file)

    limits =
      if full?,
        do: [printable_limit: :infinity, limit: :infinity],
        else: [limit: 300, printable_limit: 1000]

    IO.puts(device, "\n==================>> #{title} <<==================\n")
    IO.inspect(device, data, limits ++ [pretty: true])
    IO.puts(device, "\n^^^^^^^^^^^^^^^^^^^^ #{title} ^^^^^^^^^^^^^^^^^^^^\n")
    IO.puts(device, trace() <> "\n")

    File.close(device)

    data
  end

  def trace do
    with {_, [_ | _] = st} <- Process.info(self(), :current_stacktrace) do
      Enum.reduce(st, [], fn
        {_, _, _, [file: ~c"erl_eval.erl", line: _]}, acc -> acc
        {_, _, _, [file: ~c"src/elixir_module.erl", line: _]}, acc -> acc
        {_, _, _, [file: ~c"src/elixir_expand.erl", line: _]}, acc -> acc
        {_, _, _, [file: ~c"src/elixir_dispatch.erl", line: _]}, acc -> acc
        {_, _, _, [file: ~c"src/elixir_compiler.erl", line: _]}, acc -> acc
        {_, _, _, [file: ~c"src/elixir_lexical.erl", line: _]}, acc -> acc
        {_, _, _, [file: ~c"lists.erl", line: _]}, acc -> acc
        {_, _, _, [file: ~c"timer.erl", line: _]}, acc -> acc
        {_, _, _, [file: ~c"proc_lib.erl", line: _]}, acc -> acc
        {_, _, _, [file: ~c"gen_server.erl", line: _]}, acc -> acc
        {_, _, _, [file: ~c"src/elixir.erl", line: _]}, acc -> acc
        {_, _, _, [file: ~c"lib/iex/evaluator.ex", line: _]}, acc -> acc
        {_, _, _, [file: ~c"lib/error.ex", line: _]}, acc -> acc
        {_, _, _, [file: ~c"lib/de_bug.ex", line: _]}, acc -> acc
        {_, _, _, [file: ~c"lib/process.ex", line: _]}, acc -> acc
        {_, _, _, [file: ~c"lib/macro.ex", line: _]}, acc -> acc
        {_, _, _, [file: ~c"lib/enum.ex", line: _]}, acc -> acc
        {_, _, _, [file: ~c"lib/ex_unit/runner.ex", line: _]}, acc -> acc
        {_, _, _, [file: ~c"lib/kernel/parallel_compiler.ex", line: _]}, acc -> acc
        {m, f, a, [file: file, line: line]}, acc -> ["#{m}.#{f}/#{a} [#{file}:#{line}]" | acc]
        _, acc -> acc
      end)
      |> Enum.map(fn
        "Elixir." <> line -> line
        line -> line
      end)
      |> Enum.join("\n|> ")
    else
      _ -> "ERRORERRORERRORERROR"
    end
  end

  defp device(nil), do: :stdio

  defp device(to_file) do
    IO.puts("\n>>>>> log to #{to_file}\n")
    File.open!(to_file, [:write, :append, :utf8])
  end
end
