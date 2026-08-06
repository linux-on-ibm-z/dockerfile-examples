# Copyright IBM Corporation 2026.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Kong version 3.9.3 #########
#
# This Dockerfile builds a basic installation of Kong.
#
# Kong is a cloud-native, platform-agnostic, scalable API Gateway
# distinguished for its high performance and extensibility via plugins.
# It also provides advanced AI capabilities with multi-LLM support.
#
# To build this image, from the directory containing this Dockerfile
# Use a Personal Access Token(https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).
# This token does not need to have any other permission than Public Repositories (read-only)
# and set it as GITHUB_TOKEN environment variable.
# export GITHUB_TOKEN=<token>  
# docker build  --build-arg GITHUB_TOKEN=$GITHUB_TOKEN -t <image_name> .
#
# To Start Kong create a container from the image created from Dockerfile
# docker run -d --name <container_name> \
#   -e "KONG_DATABASE=off" \
#   -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
#   -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
#   -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
#   -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
#   -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
#   -p 8000:8000 \
#   -p 8443:8443 \
#   -p 8001:8001 \
#   -p 8444:8444 \
#   <image_name>
#
# To get started generate a skeleton configuration file kong.yml
# docker exec -it <container_name> kong config init /home/kong/kong.yml
# docker exec -it <container_name> cat /home/kong/kong.yml >> kong.yml
#################################################################################

FROM ubuntu:noble AS builder

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/open-source/)"

ARG GITHUB_TOKEN
ENV GITHUB_TOKEN=${GITHUB_TOKEN}

ARG KONG_VERSION=3.9.3
ENV KONG_VERSION=$KONG_VERSION

WORKDIR /usr/local

# Install dependencies required by build_kong.sh
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    python3 \
    git \
    unzip \
    make \
    sudo \
    openjdk-21-jdk \
    build-essential \
    automake \
    file \
    libyaml-dev \
    libprotobuf-dev \
    m4 \
    perl \
    pkg-config \
    procps \
    valgrind \
    zlib1g-dev \
    cmake \
    zip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME for build script
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-s390x/
ENV PATH="${JAVA_HOME}/bin:/usr/local/lib:${PATH}"

RUN wget https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Kong/${KONG_VERSION}/build_kong.sh && \
    chmod +x /usr/local/build_kong.sh && \
    echo "export GITHUB_TOKEN=${GITHUB_TOKEN}" >> /etc/environment && \
    bash /usr/local/build_kong.sh -y

# Install Kong's Lua sources into the luarocks tree so they appear on LUA_PATH
# at runtime. 'make build-kong' only builds native components; the Kong Lua
# modules (kong/globalpatches.lua etc.) must be installed via luarocks make.
# This is required for 'docker exec' sessions which do not invoke the
# entrypoint and therefore cannot rely on ./?.lua resolving to the source tree.
# Then resolve dangling Bazel symlinks and copy proto include files.
RUN cd /usr/local/kong && \
    . bazel-bin/build/kong-dev-venv.sh && \
    luarocks make && \
    BAZEL_OUT_DIR=$(find /root/.cache/bazel -name "kong-dev" -type d | head -n 1 | sed 's|/kong-dev$||') && \
    rm -rf bazel-* && \
    mkdir -p bazel-bin/build && \
    cp -rL "${BAZEL_OUT_DIR}/kong-dev" bazel-bin/build/kong-dev && \
    cp -rL "${BAZEL_OUT_DIR}/kong-dev-venv" bazel-bin/build/kong-dev-venv && \
    cp -rL "${BAZEL_OUT_DIR}/kong-dev-venv.sh" bazel-bin/build/kong-dev-venv.sh && \
    cp -r kong/include /usr/local/kong/include

FROM ubuntu:noble

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/open-source/)"

ARG ASSET=ce
ENV ASSET $ASSET

ARG KONG_VERSION=3.9.3
ENV KONG_VERSION $KONG_VERSION

ARG EE_PORTS

WORKDIR /usr/local

# Copy the self-contained /usr/local/kong directory from builder
COPY --from=builder /usr/local/kong /usr/local/kong

RUN apt-get update \
    && apt-get install -y --no-install-recommends libyaml-dev ca-certificates unzip git procps \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -s /bin/bash -g users -d /home/kong -m kong \
    && export KONG_VENV="/usr/local/kong/bazel-bin/build/kong-dev" \
    && touch /home/kong/kong.env && export KONG_VENV_ENV_FILE=/home/kong/kong.env \
    && bash /usr/local/kong/bazel-bin/build/kong-dev-venv/lib/venv-commons $KONG_VENV $KONG_VENV_ENV_FILE \
    && chmod 644 /home/kong/kong.env \
    && chmod -R 755 /usr/local/kong \
    && chown -R kong:0 /usr/local/kong \
    && chown -R kong:0 /home/kong \
    && ln -sf /usr/local/kong/bazel-bin/build/kong-dev/openresty/bin/resty /usr/local/bin/resty \
    && ln -sf /usr/local/kong/bazel-bin/build/kong-dev/openresty/luajit/bin/luajit /usr/local/bin/luajit \
    && ln -sf /usr/local/kong/bazel-bin/build/kong-dev/openresty/luajit/bin/luajit /usr/local/bin/lua \
    && ln -sf /usr/local/kong/bazel-bin/build/kong-dev/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
    && mkdir -p /usr/local/openresty/nginx/sbin \
    && ln -sf /usr/local/kong/bazel-bin/build/kong-dev/openresty/nginx/sbin/nginx /usr/local/openresty/nginx/sbin/nginx \
    && . /home/kong/kong.env && kong version

ENV LUA_PATH="./?.lua;./?/init.lua;/?.lua;/?/init.lua;\
/usr/local/kong/bazel-bin/build/kong-dev/share/lua/5.1/?.lua;\
/usr/local/kong/bazel-bin/build/kong-dev/share/lua/5.1/?.ljbc;\
/usr/local/kong/bazel-bin/build/kong-dev/share/lua/5.1/?/init.lua;\
/usr/local/kong/bazel-bin/build/kong-dev/share/lua/5.1/?/init.ljbc;\
/usr/local/kong/bazel-bin/build/kong-dev/openresty/site/lualib/?.lua;\
/usr/local/kong/bazel-bin/build/kong-dev/openresty/site/lualib/?.ljbc;\
/usr/local/kong/bazel-bin/build/kong-dev/openresty/site/lualib/?/init.lua;\
/usr/local/kong/bazel-bin/build/kong-dev/openresty/site/lualib/?/init.ljbc;\
/usr/local/kong/bazel-bin/build/kong-dev/openresty/lualib/?.lua;\
/usr/local/kong/bazel-bin/build/kong-dev/openresty/lualib/?.ljbc;\
/usr/local/kong/bazel-bin/build/kong-dev/openresty/lualib/?/init.lua;\
/usr/local/kong/bazel-bin/build/kong-dev/openresty/lualib/?/init.ljbc;\
/usr/local/kong/bazel-bin/build/kong-dev/openresty/luajit/share/luajit-2.1/?.lua;;" \
    LUA_CPATH="/usr/local/kong/bazel-bin/build/kong-dev/openresty/site/lualib/?.so;\
/usr/local/kong/bazel-bin/build/kong-dev/openresty/lualib/?.so;\
./?.so;\
/usr/local/kong/bazel-bin/build/kong-dev/lib/lua/5.1/?.so;\
/usr/local/kong/bazel-bin/build/kong-dev/openresty/luajit/lib/lua/5.1/?.so;\
/usr/local/kong/bazel-bin/build/kong-dev/lib/lua/5.1/?.so;;" \
    PATH="/usr/local/kong/bin:${PATH}"

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh && chown kong:0 /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD bash -c ". /home/kong/kong.env && kong health"

CMD ["kong", "docker-start"]
