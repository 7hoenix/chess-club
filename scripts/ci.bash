#! /usr/bin/env bash

set -e

mix test
npm run elm-test --prefix assets
# npm run cypress run --prefix assets
