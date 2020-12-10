# ChessClub

NOTE:
Project bootstrapped with this approach: https://blog.ispirata.com/get-started-with-elm-0-19-and-phoenix-1-4-291beebb350b

# Usage

```bash
mix phx.server
```

Install an elm dependency:

```bash
cd assets
npm run elm install mdgriffith/elm-ui
```

Deployment.

```bash
MIX_ENV=prod mix docker.build prod
MIX_ENV=prod mix ansible.playbook deploy
```

Setting up a fresh environment on AWS. Must have environment variables in place.

```bash
cd rel/terraform
terraform apply
```

TODO:

- Use python3 on webserver

BEGIN GENERATED

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

END GENERATED
