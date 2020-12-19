#! /usr/bin/env bash

set -e

npm run deploy --prefix assets

mix phx.digest.clean
mix phx.digest
MIX_ENV=prod mix docker.build prod
MIX_ENV=prod mix ansible.playbook deploy
