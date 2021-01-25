defmodule Mix.Tasks.Ansible.Playbook do
  @moduledoc "Mix task to run ansible playbooks"
  use Mix.Task

  @shortdoc "Run ansible playbooks"
  def run(args) do
    Mix.Task.run("ansible", args)
  end
end
