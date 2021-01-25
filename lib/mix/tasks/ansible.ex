defmodule Mix.Tasks.Ansible do
  @moduledoc "Run ansible playbooks"
  use Mix.Task

  def run([playbook]) do
    cmd_args = ["./rel/ansible/tasks/#{playbook}.yml"]
    {raw_dir, _resp} = System.cmd("pwd", [], env: [])
    dir = String.trim(raw_dir)
    mix_env = System.get_env("MIX_ENV")

    app_name = Atom.to_string(Mix.Project.config()[:app])
    app_version = Mix.Project.config()[:version]

    app_port =
      :chess_club
      |> Application.fetch_env!(:port)
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
