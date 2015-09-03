defmodule Test.Temp.File do
  use ExUnit.Case, async: true

  test "removes the random file on process death" do
    parent = self()

    {pid, ref} = spawn_monitor fn ->
      {:ok, path} = Temp.File.touch("sample")
      send parent, {:path, path}
      File.open!(path)
    end

    path =
      receive do
      {:path, path} -> path
    after
      1_000 -> flunk "didn't get a path"
    end

    receive do
      {:DOWN, ^ref, :process, ^pid, :normal} ->
        {:ok, _} = Temp.File.touch("sample")
        refute File.exists?(path)
    end
  end
end
