# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Development stage
FROM base as development

# Set development environment
ENV RAILS_ENV="development" \
    BUNDLE_DEPLOYMENT="0" \
    BUNDLE_PATH="/usr/local/bundle"

# Install packages needed for development
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config nodejs npm curl && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install the correct bundler version
RUN gem install bundler -v '~> 2.5' --install-dir /usr/local/lib/ruby/gems/3.2.0

# Add bundler to PATH
ENV PATH="/usr/local/lib/ruby/gems/3.2.0/bin:${PATH}"

# Install application gems (including development gems)
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Create necessary directories and set permissions
RUN mkdir -p tmp/pids tmp/sockets log && \
    chmod -R 755 tmp log

# Expose port for development
EXPOSE 5000

# Default command for development
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "5000"]

# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config

# Install the correct bundler version
RUN gem install bundler -v '~> 2.5' --install-dir /usr/local/lib/ruby/gems/3.2.0

# Add bundler to PATH
ENV PATH="/usr/local/lib/ruby/gems/3.2.0/bin:${PATH}"

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage for app image
FROM base

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
