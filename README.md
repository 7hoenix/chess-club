# ChessClub

---------------------------------------------------------------------------------------

## Mission

---------------------------------------------------------------------------------------

Want to own and operate a learning platform?

This code should help.

---------------------------------------------------------------------------------------

## Usage

---------------------------------------------------------------------------------------

```bash
source api/venv/bin/activate
```

```bash
iex -S mix phx.server
```

To run all tests: Elm, Elixir, and Cypress:

```bash
./scripts/ci.bash
```

Install an elm dependency:

```bash
npm run elm install mdgriffith/elm-ui --prefix assets
```

---------------------------------------------------------------------------------------

## First time setup

---------------------------------------------------------------------------------------

### Install python deps

This project uses a Python library for move generation.

So the first step is to wrap your python dependencies in a virtual environment:

```bash
pushd api
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.py
popd
```

To deactivate venv later:

```bash
deactivate
```

### Configure your environment variables:

This project is optimized to be used with [direnv](https://github.com/direnv/direnv)

```bash
cp .envrc{.example,}
```

Edit as needed for production. . .

---------------------------------------------------------------------------------------

## Deployment

---------------------------------------------------------------------------------------

### Elixir release

```bash
cp rel/ansible/inventory/main.yml{.example,}
```

Edit inventory file with actual nodes.

**Use the script**

```bash
./scripts/deploy_prod.bash
```

### Migrate the database

SSH into the host:
- edit `/opt/chess_club/chess_club.env` to be able to source variables
- and then run:

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

## TODO (LfG - Looking for Group)

---------------------------------------------------------------------------------------

Modules missing test coverage:

[ ] Mutation -> `makeMove`
[ ] Subcriptions -> `MoveMade`

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
