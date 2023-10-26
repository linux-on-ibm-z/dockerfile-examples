# © Copyright IBM Corporation 2017, 2023.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################################ Dockerfile for SonarQube 10.2.1 ##############################
#
# This Dockerfile builds a basic installation of SonarQube
#
# SonarQube is an open source quality management platform, dedicated to continuously analyze and measure technical quality, from project portfolio to method
#
# To build this image, from the directory containing this Dockerfile:
# docker build -t <image_name> -f SonarQube.dockerfile .
#
# Use the following command to start SonarQube container.
# docker run --name <container name> -it <image name> /bin/bash
#
# To view the web console ,start container in deamon mode and open the link mentioned below
# docker run --name <container name> -p <port_number>:9000 -d <image name>
# Link : http://<sonarQube-ip>:<port_number_9000>
######################################################################################
ARG SONARQUBE_VERSION=10.2.1.78527

FROM eclipse-temurin:17.0.7_7-jdk AS builder
LABEL stage=builder
ARG SONARQUBE_VERSION
ARG SONARQUBE_ZIP_URL=https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip
ENV JAVA_HOME='/opt/java/openjdk' \
    ES_JAVA_HOME='/opt/java/openjdk' \
    PATH="/opt/java/openjdk/bin:$PATH" \
    PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/SonarQube/10.2.1/patch/elasticsearch.diff" \
    LANG="en_US.UTF-8"

RUN apt-get update; \
    apt-get install -y wget git unzip tar net-tools xz-utils curl gzip patch locales make gcc g++; \
    locale-gen en_US.UTF-8;

# build elasticsearch
RUN git clone https://github.com/elastic/elasticsearch && \
    cd elasticsearch && \
    git checkout v8.7.0 && \
    wget $PATCH_URL && \
    git apply elasticsearch.diff && \
    curl -sSL https://github.com/elastic/elasticsearch/commit/eea68d74e1e7ac7f9dd5d7157c72641b470c2499.patch | git apply && \
    ./gradlew :distribution:archives:linux-s390x-tar:assemble --max-workers=`nproc`  --parallel

# download sonarqube and replace elasticsearch
RUN wget -q $SONARQUBE_ZIP_URL && \
    unzip sonarqube-${SONARQUBE_VERSION}.zip && \
    cd sonarqube-${SONARQUBE_VERSION} && \
    rm -rfd bin/* elasticsearch/* && \
    tar -xzf /elasticsearch/distribution/archives/linux-s390x-tar/build/distributions/elasticsearch-8.7.0-SNAPSHOT-linux-s390x.tar.gz \
        -C /sonarqube-${SONARQUBE_VERSION}/elasticsearch --strip-components 1 && \
    mv elasticsearch/bin elasticsearch/temp_bin && \
    mkdir elasticsearch/bin && \
    cp elasticsearch/temp_bin/elasticsearch-env elasticsearch/bin/ && \
    cp elasticsearch/temp_bin/elasticsearch-cli elasticsearch/bin/ && \
    rm -rfd elasticsearch/temp_bin && \
    mv elasticsearch/modules elasticsearch/temp_modules && \
    mkdir elasticsearch/modules && \
    cp -r elasticsearch/temp_modules/aggregations elasticsearch/modules/ && \
    cp -r elasticsearch/temp_modules/analysis-common elasticsearch/modules/ && \
    cp -r elasticsearch/temp_modules/apm elasticsearch/modules/ && \
    cp -r elasticsearch/temp_modules/blob-cache elasticsearch/modules/ && \
    cp -r elasticsearch/temp_modules/lang-painless elasticsearch/modules/ && \
    cp -r elasticsearch/temp_modules/old-lucene-versions elasticsearch/modules/ && \
    cp -r elasticsearch/temp_modules/parent-join elasticsearch/modules/ && \
    cp -r elasticsearch/temp_modules/reindex elasticsearch/modules/ && \
    cp -r elasticsearch/temp_modules/transport-netty4 elasticsearch/modules/ && \
    cp -r elasticsearch/temp_modules/x-pack-aggregate-metric elasticsearch/modules/ && \
    cp -r elasticsearch/temp_modules/x-pack-core elasticsearch/modules/ && \
    cp -r elasticsearch/temp_modules/x-pack-profiling elasticsearch/modules/ && \
    cp -r elasticsearch/temp_modules/x-pack-security elasticsearch/modules/ && \
    rm -rfd elasticsearch/temp_modules && \
    rm -rfd elasticsearch/jdk

FROM eclipse-temurin:17-jre as stage1
ARG SONARQUBE_VERSION=10.2.1.78527
ENV SONARQUBE_HOME=/opt/sonarqube \
    SQ_DATA_DIR="/opt/sonarqube/data" \
    SQ_EXTENSIONS_DIR="/opt/sonarqube/extensions" \
    SQ_LOGS_DIR="/opt/sonarqube/logs" \
    SQ_TEMP_DIR="/opt/sonarqube/temp"

COPY --from=builder /sonarqube-${SONARQUBE_VERSION}/ ${SONARQUBE_HOME}/

RUN set -eux; \
    groupadd --system --gid 1000 sonarqube; \
    useradd --system --uid 1000 --gid sonarqube sonarqube; \
    cd /opt; \
    ln -s "${SONARQUBE_HOME}/lib/sonar-application-${SONARQUBE_VERSION}.jar" "${SONARQUBE_HOME}/lib/sonarqube.jar"; \
    chmod -R 555 ${SONARQUBE_HOME}; \
    chmod -R ugo+wrX "${SQ_DATA_DIR}" "${SQ_EXTENSIONS_DIR}" "${SQ_LOGS_DIR}" "${SQ_TEMP_DIR}";

FROM eclipse-temurin:17-jre

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8'

#
# SonarQube setup
#
ARG SONARQUBE_VERSION=10.2.1.78527
ENV DOCKER_RUNNING="true" \
    JAVA_HOME='/opt/java/openjdk' \
    SONARQUBE_HOME=/opt/sonarqube \
    SONAR_VERSION="${SONARQUBE_VERSION}" \
    SQ_DATA_DIR="/opt/sonarqube/data" \
    SQ_EXTENSIONS_DIR="/opt/sonarqube/extensions" \
    SQ_LOGS_DIR="/opt/sonarqube/logs" \
    SQ_TEMP_DIR="/opt/sonarqube/temp"

COPY --from=stage1 ${SONARQUBE_HOME}/ ${SONARQUBE_HOME}/

RUN set -eux; \
    groupadd --system --gid 1000 sonarqube; \
    useradd --system --uid 1000 --gid sonarqube sonarqube; \
    apt-get update; \
    apt-get install -y gnupg bash fonts-dejavu; \
    echo "networkaddress.cache.ttl=5" >> "${JAVA_HOME}/conf/security/java.security"; \
    sed --in-place --expression="s?securerandom.source=file:/dev/random?securerandom.source=file:/dev/urandom?g" "${JAVA_HOME}/conf/security/java.security"; \
    # pub   2048R/D26468DE 2015-05-25
    #       Key fingerprint = F118 2E81 C792 9289 21DB  CAB4 CFCA 4A29 D264 68DE
    # uid                  sonarsource_deployer (Sonarsource Deployer) <infra@sonarsource.com>
    # sub   2048R/06855C1D 2015-05-25
    for server in $(shuf -e hkps://keys.openpgp.org \
                            hkps://keyserver.ubuntu.com) ; do \
        gpg --batch --keyserver "${server}" --recv-keys 679F1EE92B19609DE816FDE81DB198F93525EC1A && break || : ; \
    done; \
    apt-get remove -y gnupg unzip curl; \
    rm -rf /var/lib/apt/lists/*;

COPY entrypoint.sh ${SONARQUBE_HOME}/docker/
RUN chmod +x ${SONARQUBE_HOME}/docker/entrypoint.sh

WORKDIR ${SONARQUBE_HOME}
EXPOSE 9000

USER sonarqube
STOPSIGNAL SIGINT

ENTRYPOINT ["/opt/sonarqube/docker/entrypoint.sh"]
