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
ENV MIX_ENV=prod

# Prepare mounts
VOLUME /custom.d

# Expose default pleroma port to host
EXPOSE 4000

# Get dependencies
RUN \
    apk add --no-cache --virtual .tools \
        git curl rsync postgresql-client \
    \
    && apk add --no-cache --virtual .sdk \
        build-base \
    \
    && apk add --no-cache --virtual .runtime \
        imagemagick erlang erlang-runtime-tools erlang-xmerl erlang-ssl erlang-eldap elixir

# Add entrypoint
COPY ./entrypoint.sh /
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Limit permissions
ARG DOCKER_UID=1000
ARG DOCKER_GID=1000
ARG PLEROMA_UPLOADS_PATH=/uploads

RUN \
       addgroup -g ${DOCKER_GID} pleroma \
    && adduser -S -s /bin/ash -G pleroma -u ${DOCKER_UID} pleroma \
    && mkdir -p /custom.d $PLEROMA_UPLOADS_PATH \
    && chown -R pleroma:pleroma /custom.d $PLEROMA_UPLOADS_PATH

USER pleroma
WORKDIR /home/pleroma

# Get pleroma sources
RUN git clone --progress https://git.pleroma.social/pleroma/pleroma.git ./pleroma
WORKDIR /home/pleroma/pleroma

# Bust the build cache (if needed)
# This works by setting an environment variable with the last
# used version/branch/tag/commit/... which originates in the script.
# If the host doesn't have the required tool for "smart version detection"
# we'll just use the current timestamp here which forces a rebuild every time.
ARG __CACHE_TAG
ENV __CACHE_TAG $__CACHE_TAG

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
