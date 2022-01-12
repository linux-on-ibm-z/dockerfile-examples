# © Copyright IBM Corporation 2017, 2022.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################################ Dockerfile for SonarQube 9.2 ##############################
#
# This Dockerfile builds a basic installation of SonarQube
#
# SonarQube is an open source quality management platform, dedicated to continuously analyze and measure technical quality, from project portfolio to method
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Use the following command to start SonarQube container.
# docker run --name <container name> -it <image name> /bin/bash
#
# To view the web console ,start container in deamon mode and open the link mentioned below
# docker run --name <container name> -p <port_number>:9000 -d --user sonarqube <image name>
# Link : http://<sonarQube-ip>:<port_number_9000>
######################################################################################

# Base Image
FROM ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG ESUM=991f8df53079378782b9de3bbfd4c52a19920ea9ba90e9a54c871ce47b599cdb
ARG BINARY_URL=https://github.com/ibmruntimes/semeru11-binaries/releases/download/jdk-11.0.12%2B7_openj9-0.27.0/ibm-semeru-open-jdk_s390x_linux_11.0.12_7_openj9-0.27.0.tar.gz
#
# Java setup
#
RUN set -eux; \
    apt-get update && apt-get install -y curl binutils zstd gnupg unzip; \
    curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL}; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    export PATH="/opt/java/openjdk/bin:$PATH"; \
    rm -rf /var/cache/apt/*; \
    rm -rf /tmp/openjdk.tar.gz;

#
# SonarQube setup
#
ARG SONARQUBE_VERSION=9.2.4.50792
ARG SONARQUBE_ZIP_URL=https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip
ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH" \
    SONARQUBE_HOME=/opt/sonarqube \
    SONAR_VERSION="${SONARQUBE_VERSION}" \
    SQ_DATA_DIR="/opt/sonarqube/data" \
    SQ_EXTENSIONS_DIR="/opt/sonarqube/extensions" \
    SQ_LOGS_DIR="/opt/sonarqube/logs" \
    SQ_TEMP_DIR="/opt/sonarqube/temp"

RUN set -ex \
    && addgroup --gid 1000 sonarqube \
    && adduser sonarqube --disabled-password --uid 1000 --ingroup sonarqube \
    # pub   2048R/D26468DE 2015-05-25
    #       Key fingerprint = F118 2E81 C792 9289 21DB  CAB4 CFCA 4A29 D264 68DE
    # uid                  sonarsource_deployer (Sonarsource Deployer) <infra@sonarsource.com>
    # sub   2048R/06855C1D 2015-05-25
    && sed --in-place --expression="s?securerandom.source=file:/dev/random?securerandom.source=file:/dev/urandom?g" "${JAVA_HOME}/conf/security/java.security" \
    && for server in $(shuf -e ha.pool.sks-keyservers.net \
                            hkp://p80.pool.sks-keyservers.net:80 \
                            keyserver.ubuntu.com \
                            hkp://keyserver.ubuntu.com:80 \
                            pgp.mit.edu) ; do \
        gpg --batch --keyserver "${server}" --recv-keys 679F1EE92B19609DE816FDE81DB198F93525EC1A && break || : ; \
    done \
    && mkdir --parents /opt \
    && cd /opt \
    && curl --fail --location --output sonarqube.zip --silent --show-error "${SONARQUBE_ZIP_URL}" \
    && curl --fail --location --output sonarqube.zip.asc --silent --show-error "${SONARQUBE_ZIP_URL}.asc" \
    && gpg --batch --verify sonarqube.zip.asc sonarqube.zip \
    && unzip -q sonarqube.zip \
    && mv "sonarqube-${SONARQUBE_VERSION}" sonarqube \
    && rm sonarqube.zip* \
    && rm -rf ${SONARQUBE_HOME}/bin/* \
    && chown -R sonarqube:sonarqube ${SONARQUBE_HOME} \
    # this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)
    && chmod -R 777 "${SQ_DATA_DIR}" "${SQ_EXTENSIONS_DIR}" "${SQ_LOGS_DIR}" "${SQ_TEMP_DIR}"

COPY --chown=sonarqube:sonarqube run.sh sonar.sh ${SONARQUBE_HOME}/bin/
RUN chmod +x ${SONARQUBE_HOME}/bin/run.sh ${SONARQUBE_HOME}/bin/sonar.sh
WORKDIR ${SONARQUBE_HOME}
EXPOSE 9000
ENTRYPOINT ["bin/run.sh"]
CMD ["bin/sonar.sh"]
