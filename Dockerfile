ARG RUBY_VERSION=3.2.2
ARG IMAGE_FLAVOUR=alpine

FROM ruby:${RUBY_VERSION}-${IMAGE_FLAVOUR} AS base

# Install system dependencies required both at runtime and build time
ARG BUNDLER_VERSION=2.7.2

RUN apk add --update \
  git \
  postgresql-dev \
  postgresql-client \
  tzdata \
  build-base \
  libffi-dev \
  vips-dev \
  vim \
  nodejs \
  npm \
  && rm -rf /var/cache/apk/*

# Fix Alpine musl libc DNS resolution order (required for Docker embedded DNS)
RUN printf 'hosts: files dns\n' > /etc/nsswitch.conf

# Pin the bundler version at runtime as well as build time
ENV BUNDLER_VERSION=${BUNDLER_VERSION}
RUN gem install bundler -v ${BUNDLER_VERSION} --no-document

######################################################################

# This stage will be responsible for installing gems and npm packages
FROM base AS dependencies

# Install system dependencies required to build some Ruby gems (pg)
RUN apk add --update build-base
RUN mkdir /app
WORKDIR /app

COPY .ruby-version Gemfile Gemfile.lock ./

# Install gems
ARG RAILS_ENV
ENV RAILS_ENV="${RAILS_ENV}" \
  NODE_ENV="development"

# Install gems
RUN bundle config set --local frozen 'false' \
  && bundle install --no-cache --jobs "$(nproc)" --retry "$(nproc)" \
  && rm -rf /usr/local/bundle/config \
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -name "*.c" -delete \
  && find /usr/local/bundle/gems/ -name "*.o" -delete

COPY package.json package-lock.json ./

# Install npm packages
RUN npm ci --legacy-peer-deps

COPY . ./

# Optionally accept a credentials key for per-environment credentials (e.g. production.yml.enc)
ARG RAILS_MASTER_KEY
ARG SECRET_KEY_BASE

# SECRET_KEY_BASE_DUMMY=1 tells Rails to skip the real secret_key_base check during
# asset precompile, so no credentials or master key is needed at build time.
RUN SECRET_KEY_BASE_DUMMY=1 RAILS_MASTER_KEY="${RAILS_MASTER_KEY}" SECRET_KEY_BASE="${SECRET_KEY_BASE}" bundle exec rails assets:precompile

######################################################################

# We're back at the base stage
FROM base AS test

WORKDIR /app

COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/

COPY . ./

######################################################################

# We're back at the base stage
FROM base AS app

ARG RAILS_ENV
ENV RAILS_ENV="${RAILS_ENV}"

# We'll install the app in this directory
WORKDIR /app

# Copy over gems from the dependencies stage
COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/
COPY --from=dependencies /app/public/ /app/public/
COPY --from=dependencies /app/node_modules /app/node_modules

# Finally, copy over the code
# This is where the .dockerignore file comes into play
# Note that we have to use `--chown` here
COPY . ./

# Fix ruby vite cache known problem
# ActionView::Template::Error
# https://vite-ruby.netlify.app/guide/troubleshooting.html#troubleshooting
RUN /app/bin/vite build --clear --mode=${RAILS_ENV}

# Launch the server
CMD ["bin/rails", "server", "-b", "0.0.0.0"]

