#! /usr/bin/env bash

set -e

pushd assets
npm run deploy
popd

mix phx.digest
MIX_ENV=prod mix docker.build prod
MIX_ENV=prod mix ansible.playbook deploy
