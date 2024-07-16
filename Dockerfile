ARG RUBY_VERSION
ARG IMAGE_FLAVOUR=alpine

FROM ruby:$RUBY_VERSION-$IMAGE_FLAVOUR AS base

# Install system dependencies required both at runtime and build time
ARG NODE_VERSION
ARG YARN_VERSION
ARG BUNDLER_VERSION

RUN apk add --update \
  git \
  postgresql-dev \
  tzdata \
  build-base \
  libffi-dev \
  vips-dev \
  vim \
  nodejs \
  yarn

# Upgrade RubyGems and install the latest Bundler version
RUN gem update --system && \
    rm /usr/local/lib/ruby/gems/*/specifications/default/bundler-*.gemspec && \
    gem uninstall bundler && \
    gem install bundler -v $BUNDLER_VERSION --no-document

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

COPY package.json ./

# Install npm packages
RUN yarn install

COPY . ./

RUN bundle exec rails assets:precompile

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
RUN /app/bin/vite build --clear --mode=$RAILS_ENV

# Launch the server
CMD ["rails", "s"]

