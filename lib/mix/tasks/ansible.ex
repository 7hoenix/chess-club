defmodule Mix.Tasks.Ansible do
  use Mix.Task

  @shortdoc "Run ansible playbooks"
  def run([playbook]) do
    cmd_args = ["./rel/ansible/tasks/#{playbook}.yml"]
    {dir, _resp} = System.cmd("pwd", [])
    dir = String.trim(dir)
    mix_env = System.get_env("MIX_ENV")

    app_name =
      Mix.Project.config()[:app]
      |> Atom.to_string()

    app_version = Mix.Project.config()[:version]

    app_port =
      Application.fetch_env!(:chess_club, :port)
      |> to_string()

    System.cmd(
      "ansible-playbook",
      cmd_args,
      env: [
        {"ANSIBLE_CONFIG", "#{dir}/rel/ansible/ansible.cfg"},
        {"APP_NAME", app_name},
        {"APP_VSN", app_version},
        {"APP_PORT", app_port},
        {"MIX_ENV", mix_env},
        {"APP_LOCAL_RELEASE_PATH", "#{dir}/_build/#{mix_env}"}
      ],
      into: IO.stream(:stdio, :line)
    )
  end
end
