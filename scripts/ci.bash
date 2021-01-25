#! /usr/bin/env bash

set -e


echo "======Mix Compile======"
mix compile --warnings-as-errors
echo "SUCCESS"
echo ""
echo ""

echo "======Mix Credo======"
mix credo --strict
echo "SUCCESS"
echo ""
echo ""

echo "======Mix Dialyzer======"
mix dialyzer
echo "SUCCESS"
echo ""
echo ""

echo "======Mix Test======"
mix test
echo "SUCCESS"
echo ""
echo ""

echo "======Elm Test======"
npm run elm-test --prefix assets
echo "SUCCESS"
echo ""
echo ""

echo "======Cypress Integration Tests======"
# run server and redirect logging to /dev/null
mix phx.server &>/dev/null &
SERVER_PID=$!
sleep 5
npm run cypress run --prefix assets

kill $SERVER_PID

echo "SUCCESS"
echo ""
echo ""

echo "======CI Checks======"
echo ""
echo "SUCCESS: All checks passed"
echo ""
