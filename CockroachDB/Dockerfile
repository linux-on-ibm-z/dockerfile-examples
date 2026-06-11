# © Copyright IBM Corporation 2020, 2026.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################################### Dockerfile for CockroachDB version 25.4.10 ####################################
#
# To build CockroachDB image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# For more information to setup cluster, visit
# https://www.cockroachlabs.com/docs/stable/start-a-local-cluster-in-docker-linux.html
#
####################################################################################################################

# Base image
FROM us-east1-docker.pkg.dev/crl-docker-sync/registry-access-redhat-com/ubi9/ubi-minimal
ARG fips_enabled

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/open-source/)"

# For deployment, we need the following additionally installed:
# tzdata - for time zone functions; reinstalled to replace the missing
#          files in /usr/share/zoneinfo/
# hostname - used in cockroach k8s manifests
# tar - used by kubectl cp
RUN microdnf update -y \
    && rpm --erase --nodeps tzdata \
    && microdnf install tzdata hostname tar wget gzip xz -y \
    && rm -rf /var/cache/yum

RUN mkdir -p /cockroach \
    && mkdir -p /usr/local/lib/cockroach \
    && mkdir -p /docker-entrypoint-initdb.d \
    && mkdir -p /licenses 

RUN export SOURCE_ROOT=/tmp/source \
    && mkdir -p ${SOURCE_ROOT} \
    && cd ${SOURCE_ROOT} \
    && wget https://binaries.cockroachdb.com/cockroach-v25.4.10.linux-s390x.tgz \
    && tar zxf cockroach-v25.4.10.linux-s390x.tgz \
    && cp ${SOURCE_ROOT}/cockroach-v25.4.10.linux-s390x/cockroach /cockroach/ \
    && cp ${SOURCE_ROOT}/cockroach-v25.4.10.linux-s390x/lib/libgeos.so /usr/local/lib/cockroach/ \
    && cp ${SOURCE_ROOT}/cockroach-v25.4.10.linux-s390x/lib/libgeos_c.so /usr/local/lib/cockroach/ \
    && cp ${SOURCE_ROOT}/cockroach-v25.4.10.linux-s390x/LICENSE /licenses/ \
    && cp ${SOURCE_ROOT}/cockroach-v25.4.10.linux-s390x/THIRD-PARTY-NOTICES.txt /licenses/ 

RUN wget -O /cockroach/cockroach.sh \
    https://raw.githubusercontent.com/cockroachdb/cockroach/refs/tags/v25.4.10/build/deploy/cockroach.sh \
    && chmod +x /cockroach/cockroach.sh

# Set working directory so that relative paths
# are resolved appropriately when passed as args.
WORKDIR /cockroach/

# Include the directory in the path to make it easier to invoke
# commands via Docker
ENV PATH=/cockroach:$PATH

# Expose ports
EXPOSE 26257 8080
ENTRYPOINT ["/cockroach/cockroach.sh"]
