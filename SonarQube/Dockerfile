# © Copyright IBM Corporation 2017, 2026.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################################ Dockerfile for SonarQube 26.9.0 ##############################
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
ARG SONARQUBE_VERSION=26.9.0.129388

FROM eclipse-temurin:21.0.8_9-jdk AS builder
LABEL stage=builder
ARG SONARQUBE_VERSION
ARG SONARQUBE_ZIP_URL=https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip
ENV JAVA_HOME='/opt/java/openjdk' \
    ES_JAVA_HOME='/opt/java/openjdk' \
    RUNTIME_JAVA_HOME='/opt/java17' \
    PATH="/opt/java/openjdk/bin:$PATH" \
    PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/SonarQube/26.9.0/patch" \
    LANG="en_US.UTF-8"

RUN apt-get update && \
    apt-get install -y wget git unzip tar net-tools xz-utils curl gzip patch locales make gcc g++ && \
    mkdir -p /opt/java17 && \
    wget -q -O /tmp/jdk17.tar.gz \
    https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.19%2B10/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.19_10.tar.gz && \
    tar -xzf /tmp/jdk17.tar.gz -C /opt/java17 --strip-components=1 && \
    rm -f /tmp/jdk17.tar.gz && \
    locale-gen en_US.UTF-8

# build zstd for s390x
RUN ZSTD_VERSION=1.5.7 && \
    wget -q https://github.com/facebook/zstd/archive/refs/tags/v${ZSTD_VERSION}.tar.gz && \
    tar -xzf v${ZSTD_VERSION}.tar.gz && \
    cd zstd-${ZSTD_VERSION} && \
    make -j$(nproc) lib && \
    cd / && \
    mkdir -p /zstd-native-dep/artifacts/linux-s390x && \
    cp /zstd-${ZSTD_VERSION}/lib/libzstd.so \
       /zstd-${ZSTD_VERSION}/LICENSE \
       /zstd-native-dep/artifacts/linux-s390x/ && \
    jar --create \
        --no-manifest \
        --file /zstd-native-dep/zstd-${ZSTD_VERSION}-linux-s390x.jar \
        -C /zstd-native-dep/artifacts/ .

# build elasticsearch
SHELL ["/bin/bash", "-c"]
RUN git clone -b v9.4.3 https://github.com/elastic/elasticsearch.git && \
    cd elasticsearch && \
    curl -sSL "$PATCH_URL/elasticsearch.patch" | git apply - && \
	cd / && \
    git clone --depth 1 -b jansi-2.4.0 https://github.com/fusesource/jansi.git && \
    cd jansi && \
    make clean-native native OS_NAME=Linux OS_ARCH=s390x && \
    mkdir -p /jansi-jar && \
    cd /jansi-jar && \
    wget -q https://repo1.maven.org/maven2/org/fusesource/jansi/jansi/2.4.0/jansi-2.4.0.jar && \
    jar xf jansi-2.4.0.jar && \
    mkdir -p org/fusesource/jansi/internal/native/Linux/s390x && \
    cp /jansi/target/native-Linux-s390x/libjansi.so \
       org/fusesource/jansi/internal/native/Linux/s390x/ && \
    jar cf jansi-2.4.0.jar . && \
    mkdir -p /root/.gradle/caches/modules-2/files-2.1/org.fusesource.jansi/jansi/2.4.0/321c614f85f1dea6bb08c1817c60d53b7f3552fd/ && \
    cp jansi-2.4.0.jar \
       /root/.gradle/caches/modules-2/files-2.1/org.fusesource.jansi/jansi/2.4.0/321c614f85f1dea6bb08c1817c60d53b7f3552fd/ && \
    jansi_sha256=$(sha256sum jansi-2.4.0.jar | awk '{print $1}') && \
    sed -i \
       -e "s|6cd91991323dd7b2fb28ca93d7ac12af5a86a2f53279e2b35827b30313fd0b9f|${jansi_sha256}|g" \
       -e "s|616491ff68183f90e145b68874627742d796572dbfe4d8dfe64bac22a27864cb|${jansi_sha256}|g" \
       /elasticsearch/gradle/verification-metadata.xml && \
    cd /elasticsearch && \
	sed -i \
        's#%S390X_ZSTD_DEP_DIR%#/zstd-native-dep#g' \
        libs/native/libraries/build.gradle && \
    export LOCAL_VEC_BINARY_OS=linux-s390x && \
    git fetch --tags && \
    latest_tag=$(git tag | sort -V | tail -n1) && \
    latest_tag="${latest_tag:1}-SNAPSHOT" && \
    sed -i 's|${project.version}|'"${latest_tag}"'|g' x-pack/plugin/ml/build.gradle && \
    mkdir -p distribution/packages/s390x-rpm/  && \
    mkdir -p distribution/packages/s390x-deb/  && \
    mkdir -p distribution/archives/linux-s390x-tar/  && \
    mkdir -p distribution/docker/ubi-docker-s390x-export/  && \
    mkdir -p distribution/docker/cloud-docker-s390x-export/  && \
    mkdir -p distribution/docker/cloud-ess-docker-s390x-export/  && \
    mkdir -p distribution/docker/docker-s390x-export/  && \
    mkdir -p distribution/docker/ironbank-docker-s390x-export/  && \
    ES9_OPTS="" && \
    for task in \
        ":libs:entitlement:bridge:compileMain22Java" \
        ":libs:entitlement:bridge:compileMain23Java" \
        ":libs:entitlement:compileMain22Java" \
        ":libs:entitlement:compileMain23Java" \
        ":libs:entitlement:compileMain25Java" \
        ":libs:entitlement:compileMain26Java" \
        ":libs:native:compileMain22Java" \
        ":libs:simdvec:compileMain22Java"; \
    do \
        if ./gradlew -q help --task "$task" >/dev/null 2>&1; then \
            ES9_OPTS="$ES9_OPTS -x $task"; \
        fi; \
    done && \
    ./gradlew \
        :distribution:archives:linux-s390x-tar:assemble \
        $ES9_OPTS \
        --max-workers=`nproc` \
        --parallel

# download sonarqube and replace elasticsearch
RUN wget -q $SONARQUBE_ZIP_URL && \
    unzip sonarqube-${SONARQUBE_VERSION}.zip && \
    cd sonarqube-${SONARQUBE_VERSION} && \
    rm -rfd bin/elasticsearch elasticsearch/* && \
    tar -xzf /elasticsearch/distribution/archives/linux-s390x-tar/build/distributions/elasticsearch-9.4.3-SNAPSHOT-linux-s390x.tar.gz \
        -C /sonarqube-${SONARQUBE_VERSION}/elasticsearch --strip-components 1 && \
    rm -rf /sonarqube-${SONARQUBE_VERSION}/elasticsearch/modules/x-pack-ml /sonarqube-${SONARQUBE_VERSION}/elasticsearch/modules/x-pack-esql && \
    rm -rf /sonarqube-${SONARQUBE_VERSION}/elasticsearch/modules/blob-cache /sonarqube-${SONARQUBE_VERSION}/elasticsearch/modules/searchable-snapshots && \
    cp /sonarqube-${SONARQUBE_VERSION}/elasticsearch/bin/elasticsearch /sonarqube-${SONARQUBE_VERSION}/bin

FROM eclipse-temurin:21-jdk-noble AS stage1
ARG SONARQUBE_VERSION=26.9.0.129388
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
ARG SONARQUBE_VERSION=26.9.0.129388
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
