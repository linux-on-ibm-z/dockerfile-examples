# © Copyright IBM Corporation 2017, 2026.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################################ Dockerfile for SonarQube 26.10.0 ##############################
#
# This Dockerfile builds a basic installation of SonarQube
#
# SonarQube is an open source quality management platform, dedicated to continuously analyze and measure technical quality, from project portfolio to method
#
# To build this image, from the directory containing this Dockerfile:
# docker build -t <image_name> -f Dockerfile .
#
# Use the following command to start SonarQube container.
# docker run --name <container name> -it <image name> /bin/bash
#
# To view the web console ,start container in deamon mode and open the link mentioned below
# docker run --name <container name> -p <port_number>:9000 -d <image name>
# Link : http://<sonarQube-ip>:<port_number_9000>
######################################################################################
ARG SONARQUBE_VERSION=26.10.0.133078

FROM eclipse-temurin:21.0.13_9-jdk AS builder
LABEL stage=builder
ARG SONARQUBE_VERSION
ARG SONARQUBE_ZIP_URL=https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip
ENV JAVA_HOME='/opt/java/openjdk' \
    ES_JAVA_HOME='/opt/java/openjdk' \
    PATH="/opt/java/openjdk/bin:$PATH" \
    PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/SonarQube/26.10.0/patch" \
    LANG="en_US.UTF-8"

RUN apt-get update && \
    apt-get install -y wget git unzip tar net-tools xz-utils curl gzip patch locales make gcc g++ && \
    locale-gen en_US.UTF-8

# build zstd for s390x
RUN ZSTD_VERSION=1.5.7 && \
    wget -q https://github.com/facebook/zstd/archive/refs/tags/v${ZSTD_VERSION}.tar.gz && \
    tar -xzf v${ZSTD_VERSION}.tar.gz && \
    cd zstd-${ZSTD_VERSION} && \
    make -j$(nproc) lib

# build elasticsearch
SHELL ["/bin/bash", "-c"]
RUN git clone -b v9.4.7 https://github.com/elastic/elasticsearch.git && \
    cd elasticsearch && \
    curl -sSL "$PATCH_URL/elasticsearch.patch" | git apply - && \
    mkdir -p distribution/packages/s390x-rpm/  && \
    mkdir -p distribution/packages/s390x-deb/  && \
    mkdir -p distribution/archives/linux-s390x-tar/  && \
    mkdir -p distribution/docker/docker-s390x-export/  && \
    ./gradlew \
        :distribution:archives:linux-s390x-tar:assemble \
        -x :libs:entitlement:compileMain25Java \
        -x :libs:entitlement:compileMain26Java \
        -x :libs:entitlement:compileMain27Java \
        -x :libs:entitlement:qa:entitlement-test-plugin:compileMain25Java \
        -x :libs:entitlement:qa:entitlement-test-plugin:compileMain26Java \
        -x :libs:native:compileMain22Java \
        --max-workers=`nproc` \
        --parallel

# download sonarqube and replace elasticsearch
RUN wget -q $SONARQUBE_ZIP_URL && \
    unzip -q sonarqube-${SONARQUBE_VERSION}.zip && \
    cd sonarqube-${SONARQUBE_VERSION} && \
    rm -rfd bin/elasticsearch elasticsearch/* && \
    tar -xzf /elasticsearch/distribution/archives/linux-s390x-tar/build/distributions/elasticsearch-9.4.7-SNAPSHOT-linux-s390x.tar.gz \
        -C /sonarqube-${SONARQUBE_VERSION}/elasticsearch --strip-components 1 && \
    curl -sSfL "https://raw.githubusercontent.com/SonarSource/sonarqube/${SONARQUBE_VERSION}/sonar-application/build.gradle" -o /sonar-application.build.gradle && \
    grep -E "^\s+exclude '\*\*/(modules|bin|jdk)/" /sonar-application.build.gradle | sed -E "s/^\s+exclude '\*\*\///; s/'.*//; s/\/\*\*$//" | sort -u > /es_remove_list.txt && \
    while read -r p; do rm -rf "/sonarqube-${SONARQUBE_VERSION}/elasticsearch/$p"; done < /es_remove_list.txt && \
    cp /sonarqube-${SONARQUBE_VERSION}/elasticsearch/bin/elasticsearch /sonarqube-${SONARQUBE_VERSION}/bin && \
    mkdir -p /sonarqube-${SONARQUBE_VERSION}/elasticsearch/lib/platform/linux-s390x && \
    cp /zstd-1.5.7/lib/libzstd.so /sonarqube-${SONARQUBE_VERSION}/elasticsearch/lib/platform/linux-s390x/

FROM eclipse-temurin:21-jdk-noble AS stage1
ARG SONARQUBE_VERSION=26.10.0.133078
ENV SONARQUBE_HOME=/opt/sonarqube \
    SQ_DATA_DIR="/opt/sonarqube/data" \
    SQ_EXTENSIONS_DIR="/opt/sonarqube/extensions" \
    SQ_LOGS_DIR="/opt/sonarqube/logs" \
    SQ_TEMP_DIR="/opt/sonarqube/temp"

COPY --from=builder /sonarqube-${SONARQUBE_VERSION}/ ${SONARQUBE_HOME}/

RUN set -eux; \
    deluser ubuntu; \
    useradd --system --uid 1000 --gid 0 sonarqube; \
    mkdir --parents /opt; \
    cd /opt; \
    rm -rf ${SONARQUBE_HOME}/bin/*; \
    ln -s "${SONARQUBE_HOME}/lib/sonar-application-${SONARQUBE_VERSION}.jar" "${SONARQUBE_HOME}/lib/sonarqube.jar"; \
    chown -R sonarqube:root ${SONARQUBE_HOME}; \
    chown -R sonarqube:root "${SQ_DATA_DIR}" "${SQ_EXTENSIONS_DIR}" "${SQ_LOGS_DIR}" "${SQ_TEMP_DIR}"; \
    chmod -R 550 ${SONARQUBE_HOME}; \
    chmod -R 770 "${SQ_DATA_DIR}" "${SQ_EXTENSIONS_DIR}" "${SQ_LOGS_DIR}" "${SQ_TEMP_DIR}";

FROM eclipse-temurin:21-jdk-noble

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/open-source)"

ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8'

#
# SonarQube setup
#
ARG SONARQUBE_VERSION=26.10.0.133078
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
    deluser ubuntu; \
    useradd --system --uid 1000 --gid 0 sonarqube; \
    apt-get update; \
    apt-get --no-install-recommends -y install \
        bash \
        curl \
        fonts-dejavu \
        gnupg \
        unzip \
        libzstd-dev; \
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

VOLUME ["${SQ_DATA_DIR}", "${SQ_EXTENSIONS_DIR}", "${SQ_LOGS_DIR}", "${SQ_TEMP_DIR}"]

COPY --chown=root:root --chmod=555 entrypoint.sh ${SONARQUBE_HOME}/docker/

WORKDIR ${SONARQUBE_HOME}
EXPOSE 9000

USER sonarqube
STOPSIGNAL SIGINT

ENTRYPOINT ["/opt/sonarqube/docker/entrypoint.sh"]
