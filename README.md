# ChessClub

---------------------------------------------------------------------------------------

## Usage

---------------------------------------------------------------------------------------

```bash
mix phx.server
```

Install an elm dependency:

```bash
pushd assets
npm run elm install mdgriffith/elm-ui
popd
```

Deployment.

First time setup

```bash
cp rel/ansible/inventory/main.yml{.example,}
```
Edit inventory file with actual nodes.

```bash
./scripts/deploy_prod.bash
```

OR use the commands:

```bash
rm -rf priv/static
mkdir -p priv/static
npm run deploy --prefix assets

mix phx.digest.clean
mix phx.digest
MIX_ENV=prod mix docker.build prod
MIX_ENV=prod mix ansible.playbook deploy
```

Migrating the database

SSH into the host and then run:

```bash
/opt/chess_club/bin/prod eval "ChessClub.Release.migrate"
```

Setting up a fresh environment on AWS. Must have environment variables in place.

```bash
cd rel/terraform
terraform apply

MIX_ENV=prod mix ansible.playbook setup
```

---------------------------------------------------------------------------------------

## Inspirations

---------------------------------------------------------------------------------------

Want to understand how this project was built?

- Project bootstrapped with this approach: https://blog.ispirata.com/get-started-with-elm-0-19-and-phoenix-1-4-291beebb350b
- Elm structure is based on this project: https://github.com/elm/package.elm-lang.org/tree/master/src/frontend
- Elm uses Elm Program Test so that tests are testing bevavior: https://github.com/avh4/elm-program-test#basic-example

---------------------------------------------------------------------------------------

## BEGIN GENERATED

---------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------

END GENERATED

---------------------------------------------------------------------------------------
