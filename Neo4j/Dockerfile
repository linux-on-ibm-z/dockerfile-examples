# © Copyright IBM Corporation 2018, 2026.
# LICENSE: GPL v3 license, Version 3 (http://www.gnu.org/licenses)

########## Dockerfile for Neo4j version 5.26.26 ##################################
#
# This Dockerfile builds a basic installation of Neo4j.
#
# Neo4j is the world's leading Graph Database.Neo4j is available both as a standalone server, or an embeddable component.
# It is a high performance graph store with all the features expected of a mature and robust database, like a friendly query language and ACID transactions.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# For more information on how to use this image, see official documentation at https://neo4j.com/docs/operations-manual/current/docker/.
# Official website: https://neo4j.com/
#
##################################################################################

FROM redhat/ubi10-minimal:latest as builder
ARG NEO4J_VER=5.26.26

ENV SOURCE_ROOT=/tmp
ENV MAVEN_OPTS="-Xmx2048m -Xss8m"

COPY neo4j.patch $SOURCE_ROOT/neo4j.patch

RUN microdnf  install -y java-21-openjdk java-21-openjdk-devel git wget tar which \
  && cd $SOURCE_ROOT \
  && JAVA_HOME="$(dirname $(dirname $(readlink -f $(which java))))" \
  && export PATH="$JAVA_HOME/bin:$SOURCE_ROOT/apache-maven-3.9.12/bin:$PATH" \
  && wget -q https://archive.apache.org/dist/maven/maven-3/3.9.12/binaries/apache-maven-3.9.12-bin.tar.gz \
  && tar -zxf apache-maven-3.9.12-bin.tar.gz \
  && git clone --depth 1 -b 5.26.26 https://github.com/neo4j/neo4j.git \
  && cd neo4j \
  && git apply $SOURCE_ROOT/neo4j.patch \
  && mvn spotless:apply -B -V \
  && mvn clean install -B -V -DskipTests

RUN tar zxf /tmp/neo4j/packaging/standalone/target/neo4j-community-5.26.26-SNAPSHOT-unix.tar.gz -C /tmp

#base image
FROM redhat/ubi10-minimal:latest

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# gather pre-requisite packages
RUN set -eux; \
        tini_url="https://github.com/krallin/tini/releases/download/v0.19.0/tini-s390x"; \
    tini_sha="931b70a182af879ca249ae9de87ef68423121b38d235c78997fafc680ceab32d"; \
    suexec_url="https://github.com/ncopa/su-exec/releases/download/v0.3/su-exec-static-v0.3-s390x"; \
    suexec_sha="cd1ee9642b823a766a3cd1ee3241b342072f76ffa400ed0c57bd8582fd00cd99"; \
    microdnf install -y --nodocs \
        findutils \
        gnupg \
        gzip \
        hostname \
        java-21-openjdk-headless \
        jq \
        procps \
        tar \
        wget \
        which; \
    wget -q ${tini_url} -O /usr/bin/tini; \
    wget -q ${tini_url}.asc -O tini.asc; \
    echo "${tini_sha}"  /usr/bin/tini | sha256sum -c --strict --quiet; \
    chmod a+x /usr/bin/tini; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys \
        595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
        B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify tini.asc /usr/bin/tini; \
    wget -q ${suexec_url} -O /usr/bin/su-exec; \
    echo "${suexec_sha}" /usr/bin/su-exec | sha256sum -c; \
    chmod +x /usr/bin/su-exec; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME" /tini.asc; \
    microdnf clean all
ENV PATH="${JAVA_HOME}/bin:${PATH}" \
    NEO4J_EDITION=community \
    NEO4J_HOME="/var/lib/neo4j" \
    LANG=C.UTF-8
ARG NEO4J_VER=5.26.26

COPY --from=builder /tmp/neo4j-community-5.26.26-SNAPSHOT /var/lib/neo4j-community-"5.26.26"

RUN set -eux; \
    groupadd --gid 7474 --system neo4j && useradd --uid 7474 --system --no-create-home --home "${NEO4J_HOME}" --gid neo4j neo4j; \
    mv /var/lib/neo4j-* "${NEO4J_HOME}"; \
    sed -i 's/Package Type:.*/Package Type: docker ubi10/' $NEO4J_HOME/packaging_info; \
     mkdir -p /startup; \
     wget https://raw.githubusercontent.com/neo4j/docker-neo4j-publish/master/"${NEO4J_VER}"/ubi10/community/local-package/docker-entrypoint.sh -P /startup; \
     wget https://raw.githubusercontent.com/neo4j/docker-neo4j-publish/master/"${NEO4J_VER}"/ubi10/community/local-package/neo4j-admin-report.sh -P /startup; \
     wget https://raw.githubusercontent.com/neo4j/docker-neo4j-publish/master/"${NEO4J_VER}"/ubi10/community/local-package/neo4j-plugins.json -P /startup; \
     wget https://raw.githubusercontent.com/neo4j/docker-neo4j-publish/master/"${NEO4J_VER}"/ubi10/community/local-package/utilities.sh -P /startup; \
     wget https://raw.githubusercontent.com/neo4j/docker-neo4j-publish/master/"${NEO4J_VER}"/ubi10/community/local-package/semver.jq -P /startup; \
     chmod +x /startup/neo4j-admin-report.sh /startup/docker-entrypoint.sh /startup/utilities.sh /startup/semver.jq; \
     mv /startup/neo4j-admin-report.sh "${NEO4J_HOME}"/bin/neo4j-admin-report; \
     mv "${NEO4J_HOME}"/data /data; \
     mv "${NEO4J_HOME}"/logs /logs; \
     chown -R neo4j:neo4j /data; \
     chmod -R 777 /data; \
     chown -R neo4j:neo4j /logs; \
     chmod -R 777 /logs; \
     chown -R neo4j:neo4j "${NEO4J_HOME}"; \
     chmod -R 777 "${NEO4J_HOME}"; \
     chmod -R 755 "${NEO4J_HOME}/bin"; \
     ln -s /data "${NEO4J_HOME}"/data; \
     ln -s /logs "${NEO4J_HOME}"/logs

ENV PATH="${NEO4J_HOME}"/bin:$PATH

WORKDIR "${NEO4J_HOME}"

VOLUME /data /logs

EXPOSE 7474 7473 7687

ENTRYPOINT ["tini", "-g", "--", "/startup/docker-entrypoint.sh"]
CMD ["neo4j"]
