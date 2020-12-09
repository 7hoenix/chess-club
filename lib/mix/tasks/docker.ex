defmodule Mix.Tasks.Docker do
  use Mix.Task
  use Mix.Tasks.Utils

  @shortdoc "Docker utilities for building releases."
  def run([env]) do
    build_image(env)

    {dir, _resp} = System.cmd("pwd", [])

    docker(
      "run -v #{String.trim(dir)}:/opt/build --rm -i #{app_name()}:latest /opt/build/bin/release #{env}"
    )
  end

  defp build_image(env) do
    docker("build --build-arg ENV=#{env} -t #{app_name()}:latest .")
  end

  defp docker(cmd) do
    System.cmd("docker", String.split(cmd, " "), into: IO.stream(:stdio, :line))
  end
end
