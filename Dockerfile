# Dockerfile reference
# https://docs.docker.com/engine/reference/builder/#usage
FROM sorah/ruby:2.7-focal

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

RUN apt-get update && \
  apt-get install -y curl git-core build-essential apt-transport-https gnupg2 tzdata libmysqlclient-dev libssl-dev libxml2-dev ruby-dev && \
  apt-get clean && rm -rf /var/lib/apt/lists/* # Cleanup temporary data to reduce image size

# We need package manager at first.
RUN gem install bundler -v 2.1.4

# Let bundler install gems with different place to reuse cache layer.
# If source have no change with Gemfile{,.lock},
# we can reuse L16 image layer to reduce build time.
COPY Gemfile /tmp/Gemfile
COPY Gemfile.lock /tmp/Gemfile.lock
RUN cd /tmp && \
    bundle config set path 'vendor/bundle' && \
    bundle install -j4

WORKDIR /app
COPY . /app
RUN cp -a /tmp/.bundle /tmp/vendor /app/
# Precompile css and js with sprockets
RUN bin/rails assets:precompile RAILS_ENV=production

CMD ["bundle", "exec", "rails", "server"]
