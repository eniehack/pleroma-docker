FROM alpine:3.10

ARG __VIA_SCRIPT
RUN \
    if [ -z "$__VIA_SCRIPT" ]; then \
        echo -e "\n\nERROR\nYou must build pleroma via build.sh\n\n"; \
        exit 1; \
    fi

# Set up environment
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ARG MIX_ENV
ENV MIX_ENV=$MIX_ENV

# Prepare mounts
VOLUME /custom.d /uploads

# Expose HTTP, Gopher, and SSH ports, respectively
EXPOSE 4000 9999 2222

# Get dependencies
RUN \
    apk add --no-cache --virtual .tools \
        git curl rsync postgresql-client \
    && \
    apk add --no-cache --virtual .sdk \
        build-base \
    && \
    apk add --no-cache --virtual .runtime \
        imagemagick \
        elixir erlang erlang-runtime-tools \
        erlang-xmerl erlang-ssl erlang-ssh erlang-eldap erlang-mnesia

# Add entrypoint
COPY ./entrypoint.sh /
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Limit permissions
ARG DOCKER_UID
ARG DOCKER_GID
RUN \
    echo "#> Pleroma user will be ${DOCKER_UID}:${DOCKER_GID}" 1>&2 && \
    addgroup -g ${DOCKER_GID} pleroma && \
    adduser -S -s /bin/ash -G pleroma -u ${DOCKER_UID} pleroma && \
    mkdir -p /custom.d /uploads && \
    chown -R pleroma:pleroma /custom.d /uploads

USER pleroma
WORKDIR /home/pleroma

# Get pleroma sources
ARG PLEROMA_GIT_REPO
RUN \
    echo "#> Getting pleroma sources from $PLEROMA_GIT_REPO..." 1>&2 && \
    git clone --progress $PLEROMA_GIT_REPO ./pleroma

WORKDIR /home/pleroma/pleroma

# Bust the build cache (if needed)
# This works by setting an environment variable with the last
# used version/branch/tag/commit/... which originates in the script.
ARG __CACHE_TAG
ENV __CACHE_TAG $__CACHE_TAG

# Fetch changes, checkout
ARG PLEROMA_VERSION
RUN \
    git fetch --all && \
    git checkout $PLEROMA_VERSION && \
    git pull --rebase --autostash

# Precompile
RUN \
    cp ./config/dev.exs ./config/prod.secret.exs && \
    BUILDTIME=1 /entrypoint.sh && \
    rm ./config/prod.secret.exs
