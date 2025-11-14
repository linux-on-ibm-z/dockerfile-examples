# syntax=docker/dockerfile:1
# Copyright IBM Corporation 2025.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################ Dockerfile for pgvector 0.8.1 ############################################
#
# This Dockerfile builds a basic installation of pgvector.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start pgvector service using this image, use following command:
# docker run --name <container name> -e POSTGRES_PASSWORD=pass -d <image name>
#
################################################################################################################
ARG PG_MAJOR=17
ARG DEBIAN_CODENAME=bookworm

# Build PostgreSQL + pgvector
FROM ubuntu:22.04 AS builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/open-source/)"

ARG PG_MAJOR
ENV PG_SRC_DIR=/usr/local/src/postgresql

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    bison flex wget build-essential git gcc tar make zlib1g-dev libreadline-dev patch curl && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Download and build PostgreSQL from source
WORKDIR /usr/local/src
RUN wget https://ftp.postgresql.org/pub/source/v${PG_MAJOR}.0/postgresql-${PG_MAJOR}.0.tar.gz && \
    tar xf postgresql-${PG_MAJOR}.0.tar.gz && \
    cd postgresql-${PG_MAJOR}.0 && \
    ./configure --without-icu --prefix=/usr/local/pgsql && \
    make -j$(nproc) && \
    make install

# Build pgvector
RUN git clone -b v0.8.1 https://github.com/pgvector/pgvector.git /tmp/pgvector && \
    cd /tmp/pgvector && \
    PATH=/usr/local/pgsql/bin:$PATH make OPTFLAGS="" && \
    PATH=/usr/local/pgsql/bin:$PATH make install && \
    rm -rf /tmp/pgvector

## Runtime image
FROM postgres:$PG_MAJOR-$DEBIAN_CODENAME

# Copy binaries and libraries from builder stage
COPY --from=builder /usr/local/pgsql /usr/local/pgsql

# Update PATH so postgres uses our custom build
ENV PATH="/usr/local/pgsql/bin:$PATH"


