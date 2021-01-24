FROM elixir:1.11

ARG env=prod
ARG secret_key_base
ARG db_hostname
ARG db_username
ARG db_password

ENV MIX_ENV=$env
ENV SECRET_KEY_BASE=$secret_key_base
ENV DATABASE_HOST_PROD=$db_hostname
ENV DATABASE_USER_PROD=$db_username
ENV DATABASE_PASSWORD_PROD=$db_password

WORKDIR /opt/build

RUN apt-get make gcc libc-dev

ADD ./bin/release ./bin/release

CMD ["bin/release", $ENV]
