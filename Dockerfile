# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t job_board .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name job_board job_board

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.5
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages including ClamAV and sudo
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl libjemalloc2 libvips sqlite3 libffi-dev \
    clamav clamav-daemon clamav-freshclam sudo && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Configure ClamAV
RUN mkdir -p /var/lib/clamav /var/log/clamav /run/clamav && \
    chown -R clamav:clamav /var/lib/clamav /var/log/clamav /run/clamav && \
    chmod 755 /var/lib/clamav /var/log/clamav /run/clamav

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    RAILS_HOST="0.0.0.0" \
    RAILS_WEB_URL="https://jobboard-staging.fly.dev" \
    HTTP_PORT="8080" \
    STAGING_ENV="true"

# Some env vars are build-time only, later they wil be picked up from the container runtime environment

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

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

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Create ClamAV configuration
RUN echo "LocalSocket /run/clamav/clamd.ctl" > /etc/clamav/clamd.conf && \
    echo "LocalSocketGroup clamav" >> /etc/clamav/clamd.conf && \
    echo "LocalSocketMode 666" >> /etc/clamav/clamd.conf && \
    echo "User clamav" >> /etc/clamav/clamd.conf && \
    echo "ScanMail yes" >> /etc/clamav/clamd.conf && \
    echo "ScanArchive yes" >> /etc/clamav/clamd.conf && \
    echo "ArchiveBlockEncrypted no" >> /etc/clamav/clamd.conf && \
    echo "MaxScanSize 100M" >> /etc/clamav/clamd.conf && \
    echo "MaxFileSize 25M" >> /etc/clamav/clamd.conf && \
    echo "MaxRecursion 10" >> /etc/clamav/clamd.conf && \
    echo "MaxFiles 15000" >> /etc/clamav/clamd.conf && \
    echo "MaxEmbeddedPE 10M" >> /etc/clamav/clamd.conf && \
    echo "MaxHTMLNormalize 10M" >> /etc/clamav/clamd.conf && \
    echo "MaxHTMLNoTags 2M" >> /etc/clamav/clamd.conf && \
    echo "MaxScriptNormalize 5M" >> /etc/clamav/clamd.conf && \
    echo "MaxZipTypeRcg 1M" >> /etc/clamav/clamd.conf && \
    echo "DatabaseDirectory /var/lib/clamav" >> /etc/clamav/clamd.conf && \
    echo "LogFile /var/log/clamav/clamav.log" >> /etc/clamav/clamd.conf && \
    echo "LogTime yes" >> /etc/clamav/clamd.conf

# Configure freshclam for virus definition updates
RUN echo "DatabaseDirectory /var/lib/clamav" > /etc/clamav/freshclam.conf && \
    echo "UpdateLogFile /var/log/clamav/freshclam.log" >> /etc/clamav/freshclam.conf && \
    echo "LogTime yes" >> /etc/clamav/freshclam.conf && \
    echo "DatabaseOwner clamav" >> /etc/clamav/freshclam.conf && \
    echo "DNSDatabaseInfo current.cvd.clamav.net" >> /etc/clamav/freshclam.conf && \
    echo "DatabaseMirror db.local.clamav.net" >> /etc/clamav/freshclam.conf && \
    echo "DatabaseMirror database.clamav.net" >> /etc/clamav/freshclam.conf

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

# Fix the data storage directory ownership issue
RUN mkdir -p /data/storage && chown -R rails:rails /data && chmod -R 755 /data

# Add rails user to clamav group for socket access and configure sudo
RUN usermod -a -G clamav rails && \
    echo "rails ALL=(clamav) NOPASSWD: /usr/sbin/clamd" >> /etc/sudoers

# Create startup script for ClamAV and Rails
RUN echo '#!/bin/bash' > /rails/bin/start-with-clamav && \
    echo 'set -e' >> /rails/bin/start-with-clamav && \
    echo '' >> /rails/bin/start-with-clamav && \
    echo '# Start ClamAV daemon in background' >> /rails/bin/start-with-clamav && \
    echo 'sudo -u clamav /usr/sbin/clamd &' >> /rails/bin/start-with-clamav && \
    echo '' >> /rails/bin/start-with-clamav && \
    echo '# Wait for ClamAV socket to be ready' >> /rails/bin/start-with-clamav && \
    echo 'timeout=30' >> /rails/bin/start-with-clamav && \
    echo 'while [ $timeout -gt 0 ] && [ ! -S /run/clamav/clamd.ctl ]; do' >> /rails/bin/start-with-clamav && \
    echo '  echo "Waiting for ClamAV daemon to start..."' >> /rails/bin/start-with-clamav && \
    echo '  sleep 1' >> /rails/bin/start-with-clamav && \
    echo '  timeout=$((timeout-1))' >> /rails/bin/start-with-clamav && \
    echo 'done' >> /rails/bin/start-with-clamav && \
    echo '' >> /rails/bin/start-with-clamav && \
    echo 'if [ ! -S /run/clamav/clamd.ctl ]; then' >> /rails/bin/start-with-clamav && \
    echo '  echo "ClamAV daemon failed to start"' >> /rails/bin/start-with-clamav && \
    echo '  exit 1' >> /rails/bin/start-with-clamav && \
    echo 'fi' >> /rails/bin/start-with-clamav && \
    echo '' >> /rails/bin/start-with-clamav && \
    echo 'echo "ClamAV daemon started successfully"' >> /rails/bin/start-with-clamav && \
    echo '' >> /rails/bin/start-with-clamav && \
    echo '# Execute the original entrypoint and command' >> /rails/bin/start-with-clamav && \
    echo 'exec "$@"' >> /rails/bin/start-with-clamav && \
    chmod +x /rails/bin/start-with-clamav

USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/start-with-clamav", "/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 8080
CMD ["./bin/thrust", "./bin/rails", "server"]
