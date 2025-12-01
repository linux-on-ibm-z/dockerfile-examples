# © Copyright IBM Corporation 2025
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################### Dockerfile for Apache Kafka 4.1.1 ############################
#
# Apache Kafka is an open-source event streaming platform used to collect, 
# process, store, and integrate data at scale in real time. It powers 
# numerous use cases including stream processing, data integration, and 
# pub/sub messaging.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start a Kafka broker:
#
# $ docker run -d --name broker <image_name>
#
# For more information, see https://hub.docker.com/r/apache/kafka
###############################################################################

FROM eclipse-temurin:21-jre-noble AS build-jsa

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/open-source/)"

USER root

ENV kafka_url https://archive.apache.org/dist/kafka/4.1.1/kafka_2.13-4.1.1.tgz

RUN set -eux ; \
    apt update ; \
    apt upgrade -y ; \
    apt install -y wget gpg gpg-agent procps bash; \
    mkdir opt/kafka; \
    wget -nv -O kafka.tgz "$kafka_url"; \
    tar xfz kafka.tgz -C /opt/kafka --strip-components 1; \
    mkdir -p /etc/kafka/docker; \
    wget -O /etc/kafka/docker/jsa_launch https://raw.githubusercontent.com/apache/kafka/refs/tags/4.1.1/docker/jvm/jsa_launch; \
    chmod +x /etc/kafka/docker/jsa_launch; \
    wget -O /etc/kafka/docker/server.properties https://raw.githubusercontent.com/apache/kafka/refs/tags/4.1.1/docker/server.properties

# Generate jsa files using dynamic CDS for kafka server start command and kafka storage format command
RUN /etc/kafka/docker/jsa_launch


FROM eclipse-temurin:21-jre-noble

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# exposed ports
EXPOSE 9092

USER root

ENV kafka_url https://archive.apache.org/dist/kafka/4.1.1/kafka_2.13-4.1.1.tgz

RUN set -eux ; \
    apt update ; \
    apt upgrade -y ; \
    apt install -y wget gpg gpg-agent procps bash; \
    mkdir opt/kafka; \
    wget -nv -O kafka.tgz "$kafka_url"; \
    tar xfz kafka.tgz -C /opt/kafka --strip-components 1; \
    mkdir -p /var/lib/kafka/data /etc/kafka/secrets; \
    mkdir -p /etc/kafka/docker /usr/logs /mnt/shared/config; \
    adduser --home /home/appuser --disabled-password --shell /bin/bash appuser; \
    chown appuser:appuser -R /usr/logs /opt/kafka /mnt/shared/config; \
    chown appuser:root -R /var/lib/kafka /etc/kafka/secrets /etc/kafka; \
    chmod -R ug+w /etc/kafka /var/lib/kafka /etc/kafka/secrets; \
    cp /opt/kafka/config/log4j2.yaml /etc/kafka/docker/log4j2.yaml; \
    cp /opt/kafka/config/tools-log4j2.yaml /etc/kafka/docker/tools-log4j2.yaml; \
    rm kafka.tgz; \
    cd /etc/kafka/docker; \
    wget -O bash-config       https://github.com/apache/kafka/raw/refs/tags/4.1.1/docker/resources/common-scripts/bash-config; \
    wget -O configure         https://github.com/apache/kafka/raw/refs/tags/4.1.1/docker/resources/common-scripts/configure; \
    wget -O configureDefaults https://github.com/apache/kafka/raw/refs/tags/4.1.1/docker/resources/common-scripts/configureDefaults; \
    wget -O run               https://github.com/apache/kafka/raw/refs/tags/4.1.1/docker/resources/common-scripts/run; \
    wget -O launch            https://github.com/apache/kafka/raw/refs/tags/4.1.1/docker/jvm/launch; \
    chmod +x configure configureDefaults run launch; \
    chown appuser:appuser bash-config configure configureDefaults run launch; \
    apt-get -y purge --auto-remove wget gpg gpg-agent; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/*;

COPY --from=build-jsa /etc/kafka/docker/server.properties /etc/kafka/docker/server.properties
COPY --from=build-jsa kafka.jsa /opt/kafka/kafka.jsa
COPY --from=build-jsa storage.jsa /opt/kafka/storage.jsa

USER appuser

VOLUME ["/etc/kafka/secrets", "/var/lib/kafka/data", "/mnt/shared/config"]

CMD ["/etc/kafka/docker/run"]
