FROM debian:9-slim

# Set up environment
ENV MIX_ENV=prod
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Prepare mounts
VOLUME /custom.d

# Expose default pleroma port to host
EXPOSE 4000

# Get erlang, elixir, and dependencies
RUN \
       apt-get update \
    && apt-get install -y --no-install-recommends apt-utils \
    && apt-get install -y --no-install-recommends git wget ca-certificates gnupg2 build-essential ruby \
    \
    && wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
    && dpkg -i erlang-solutions_1.0_all.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends esl-erlang elixir \
    \
    && rm -rf /var/lib/apt/lists/*

# Add entrypoint
COPY ./entrypoint.sh /
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Limit permissions
ARG DOCKER_UID=1000
ARG DOCKER_GID=1000
ARG PLEROMA_UPLOADS_PATH=/uploads

RUN \
       groupadd --gid ${DOCKER_GID} pleroma \
    && useradd -m -s /bin/bash --gid ${DOCKER_GID} --uid ${DOCKER_UID} pleroma \
    && mkdir -p /custom.d $PLEROMA_UPLOADS_PATH \
    && chown -R pleroma:pleroma /custom.d $PLEROMA_UPLOADS_PATH

USER pleroma
WORKDIR /home/pleroma

# Get pleroma sources
RUN git clone --progress https://git.pleroma.social/pleroma/pleroma.git ./pleroma
WORKDIR /home/pleroma/pleroma

# Bust the build cache (if needed)
# This works by setting an environment variable with the last
# used version/branch/tag/commitish/... which originates in the script.
# If the host doesn't have the required tool for "smart version detection"
# we'll just use the current timestamp here which forces a rebuild every time.
ARG __BUST_CACHE
ENV __BUST_CACHE $__BUST_CACHE

# Fetch changes, checkout
ARG PLEROMA_VERSION
RUN \
       git fetch --all \
    && git checkout $PLEROMA_VERSION \
    && git pull --rebase --autostash

# Precompile
RUN \
    cp ./config/dev.exs ./config/prod.secret.exs \
    && BUILDTIME=1 /entrypoint.sh \
    && rm ./config/prod.secret.exs

# Insert overrides
COPY --chown=pleroma:pleroma ./custom.d /home/pleroma/pleroma
