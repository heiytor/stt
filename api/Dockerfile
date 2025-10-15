# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.4.5
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libjemalloc2 libpq5 curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ARG RAILS_ENV
ARG BUNDLE_WITHOUT
ARG BUNDLE_PATH

ENV RAILS_ENV=${RAILS_ENV:-production} \
    BUNDLE_WITHOUT=${BUNDLE_WITHOUT} \
    BUNDLE_PATH=${BUNDLE_PATH} \
    LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libjemalloc.so.2" \
    MALLOC_CONF="background_thread:true,metadata_thp:auto,dirty_decay_ms:5000,muzzy_decay_ms:5000,narenas:2" \
    RUBY_YJIT_ENABLE="1"

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Estágio de build - onde instalamos gems e compilamos assets
FROM base AS build

# Instala ferramentas de compilação necessárias para gems nativas
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git pkg-config libyaml-dev libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copia os arquivos de definição de gems e instala todas as dependências
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copia o restante do código da aplicação
COPY . .

# Pré-compila código Ruby para melhorar performance de inicialização
RUN bundle exec bootsnap precompile app/ lib/

# Estágio de desenvolvimento - imagem otimizada para ambiente de desenvolvimento
FROM base AS development

# Copia as gems instaladas e código da aplicação do estágio de build
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

CMD ["/rails/bin/bundle", "exec", "foreman", "start", "--env", "/dev/null", "-f", "./Procfile.dev"]
