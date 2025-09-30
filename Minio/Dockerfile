# © Copyright IBM Corporation 2025.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
#
###################### Dockerfile for Minio - RELEASE.2025-09-07T16-13-09Z########################
#
# MinIO is a High Performance Object Storage released under GNU Affero General Public License v3.0. 
# It is API compatible with Amazon S3 cloud storage service. 
# Use MinIO to build high performance infrastructure for machine learning, analytics and application data workloads.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build --build-arg RELEASE="${Minio_release}" --build-arg MC_RELEASE="${mc_release}" -t  <image_name> --platform=linux/s390x .
#
# To start a Minio sever:
# docker run -d -p 9000:9000 -p 9001:9001 <image_name> server /data --console-address ":9001"
#
#
# For more information, see https://github.com/minio/minio/tree/master?tab=readme-ov-file#container-installation
#####################################################################

FROM golang:1.24-alpine AS build

ARG TARGETARCH
ARG RELEASE
ARG MC_RELEASE
ENV GOPATH=/go
ENV CGO_ENABLED=0

WORKDIR /build

# Install curl and minisign
RUN apk add -U --no-cache ca-certificates && \
    apk add -U --no-cache curl && \
    apk add -U --no-cache bash && \
    apk add -U --no-cache make && \
    apk add -U --no-cache git && \
    apk add -U --no-cache perl && \
    go install aead.dev/minisign/cmd/minisign@v0.2.1

# Building minio binary 
RUN git clone -b ${RELEASE} https://github.com/minio/minio.git && \
    cd minio && \
    make  && \
    make install  && \
    cp dockerscripts/download-static-curl.sh /build/download-static-curl && \
    cp dockerscripts/docker-entrypoint.sh /build/docker-entrypoint.sh && \
    cp CREDITS /build/CREDITS && \
    cp LICENSE /build/LICENSE && \
    chmod +x /go/bin/minio

# Building mc binary
RUN git clone -b ${MC_RELEASE} https://github.com/minio/mc.git && \
    cd mc && \
    make  && \
    make install  && \
    chmod +x /go/bin/mc

RUN chmod +x /build/download-static-curl && \
    /build/download-static-curl

FROM registry.access.redhat.com/ubi9/ubi-micro:latest

ARG RELEASE

LABEL name="MinIO" \
      vendor="MinIO Inc <dev@min.io>" \
      maintainer="MinIO Inc <dev@min.io>" \
      version="${RELEASE}" \
      release="${RELEASE}" \
      summary="MinIO is a High Performance Object Storage, API compatible with Amazon S3 cloud storage service." \
      description="MinIO object storage is fundamentally different. Designed for performance and the S3 API, it is 100% open-source. MinIO is ideal for large, private cloud environments with stringent security requirements and delivers mission-critical availability across a diverse range of workloads."

ENV MINIO_ACCESS_KEY_FILE=access_key \
    MINIO_SECRET_KEY_FILE=secret_key \
    MINIO_ROOT_USER_FILE=access_key \
    MINIO_ROOT_PASSWORD_FILE=secret_key \
    MINIO_KMS_SECRET_KEY_FILE=kms_master_key \
    MINIO_UPDATE_MINISIGN_PUBKEY="RWTx5Zr1tiHQLwG9keckT0c45M3AGeHD6IvimQHpyRywVWGbP1aVSGav" \
    MINIO_CONFIG_ENV_FILE=config.env \
    MC_CONFIG_DIR=/tmp/.mc

RUN chmod -R 777 /usr/bin

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /go/bin/minio* /usr/bin/
COPY --from=build /go/bin/mc* /usr/bin/
COPY --from=build /go/bin/curl* /usr/bin/
COPY --from=build /build/docker-entrypoint.sh /usr/bin/
COPY --from=build /build/LICENSE /licenses/
COPY --from=build /build/CREDITS /licenses/

RUN chmod +x /usr/bin/docker-entrypoint.sh

EXPOSE 9000
VOLUME ["/data"]

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["minio"]
