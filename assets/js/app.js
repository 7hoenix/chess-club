// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"

import * as AbsintheSocket from "@absinthe/socket";
import { Socket as PhoenixSocket } from "phoenix";
import { Elm } from "../src/Main.elm";

let notifiers = [];

document.addEventListener("DOMContentLoaded", function() {
  const socketUrl = document.querySelector('body').dataset.socketEndpoint
  const absintheSocket = AbsintheSocket.create(
    new PhoenixSocket(socketUrl + "/socket")
  );

  const app = Elm.Main.init({
      flags: {
        backendEndpoint: document.querySelector('body').dataset.backendEndpoint,
        authToken: document.querySelector('body').dataset.authToken
      }
  });
  app.ports.createSubscriptions.subscribe(function(subscription) {
    console.log("createSubscriptions called with", [subscription]);
    // Remove existing notifiers
    notifiers.map(notifier => AbsintheSocket.cancel(absintheSocket, notifier));

    // Create new notifiers for each subscription sent
    notifiers = [subscription].map(operation =>
      AbsintheSocket.send(absintheSocket, {
        operation,
        variables: {}
      })
    );

    function onStart(data) {
      console.log(">>> Start", JSON.stringify(data));
      app.ports.socketStatusConnected.send(null);
    }

    function onAbort(data) {
      console.log(">>> Abort", JSON.stringify(data));
    }

    function onCancel(data) {
      console.log(">>> Cancel", JSON.stringify(data));
    }

    function onError(data) {
      console.log(">>> Error", JSON.stringify(data));
      app.ports.socketStatusReconnecting.send(null);
    }

    function onResult(res) {
      console.log(">>> Result", JSON.stringify(res));
      app.ports.gotSubscriptionData.send(res);
    }

    notifiers.map(notifier =>
      AbsintheSocket.observe(absintheSocket, notifier, {
        onAbort,
        onError,
        onCancel,
        onStart,
        onResult
      })
    );
  });
});
