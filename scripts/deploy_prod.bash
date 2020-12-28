#! /usr/bin/env bash

set -e

echo "Running CI"
./scripts/ci.bash

rm -rf priv/static
mkdir -p priv/static
npm run deploy --prefix assets

mix phx.digest.clean
mix phx.digest
MIX_ENV=prod mix docker.build prod
MIX_ENV=prod mix ansible.playbook deploy
