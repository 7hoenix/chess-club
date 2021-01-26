#! /usr/bin/env bash

set -e

function _print_success() {
  echo "✅ SUCCESS"
  echo ""
  echo ""
}

function _compile() {
  echo "======Mix Compile======"
  mix compile --warnings-as-errors
  _print_success
}

function _credo() {
  echo "======Mix Credo======"
  mix credo --strict
  _print_success
}

function _dialyzer() {
  echo "======Mix Dialyzer======"
  mix dialyzer
  _print_success

}

function _mix_test() {
  echo "======Mix Test======"
  mix test
  _print_success
}

function _elm_test() {
  echo "======Elm Test======"
  npm run elm-test --prefix assets
  _print_success
}

function _start_server() {
  # run server and redirect logging to /dev/null
  mix phx.server &>/dev/null &
  # save server PID
  _server_pid=$!
}

function _kill_server() {
  kill $_server_pid
}

function _integration() {
  echo "======Cypress Integration Tests======"
  _start_server
  # kill server on exit
  trap _kill_server EXIT
  sleep 5
  npm run cypress run --prefix assets
  _print_success
}

function _xref() {
  echo "======Xref Generation======"
  echo ""
  mix xref graph --format dot
  dot -Tpng -Grankdir=LR xref_graph.dot -o xref_graph.png
}

function _print_xref_link() {
  echo "Command click the link below to view the xref graph."
  echo "file://$(pwd)/xref_graph.png"
}

function _print_all_pass() {
  echo ""
  echo ""
  echo ""
  echo ""
  echo "✅ SUCCESS: All checks passed 🎉"
  echo ""
}

_compile
_credo
_dialyzer
_mix_test
_elm_test
#_integration
_xref
_print_xref_link
_print_all_pass

