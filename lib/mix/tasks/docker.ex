defmodule Mix.Tasks.Docker do
  use Mix.Task

  @shortdoc "Docker utilities for building releases."
  def run([env]) do
    build_image(env)

    {dir, _resp} = System.cmd("pwd", [])

    docker(
      "run -v #{String.trim(dir)}:/opt/build --rm -i #{app_name()}:latest /opt/build/bin/release #{env}"
    )
  end

  defp build_image(env) do
    docker("build --build-arg ENV=#{env} SECRET_KEY_BASE='Nyvf7xqh3p18qU6CVUpwjHzlR7ZOaEwRI7e0vuTQdvjQMkfbTBSbpiU+qNMasnxf' -t #{app_name()}:latest .")
  end

  defp docker(cmd) do
    System.cmd("docker", String.split(cmd, " "), into: IO.stream(:stdio, :line))
  end

  defp app_name() do
    "chess_club"
  end
end
