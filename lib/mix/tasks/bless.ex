defmodule Mix.Tasks.Bless do
  use Mix.Task

  @shortdoc "Runs all checks required to push project to repo"
  def run(_) do
    [
      {"compile", ["--warnings-as-errors", "--force"]},
      {"format", ["--check-formatted"]},
      {"coveralls.html", []},
      {"dialyzer", []},
      {"docs", []}
    ]
    |> Enum.each(fn {task, args} ->
      IO.ANSI.format([:cyan, "Running #{task} with args #{inspect(args)}"])
      |> IO.puts()

      Mix.Task.run(task, args)
    end)
  end
end
