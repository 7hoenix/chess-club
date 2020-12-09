FROM elixir:1.11

ARG ENV=prod

ENV MIX_ENV=$ENV
ENV DATABASE_URL=foo
ENV SECRET_KEY_BASE=am+MWs51dckunY73YW9E/nRnbxQfelm3V7rHedQMOu6Rsz7515edK4tiXb7mvcYe

WORKDIR /opt/build

ADD ./bin/release ./bin/release

CMD ["bin/release", $ENV]
