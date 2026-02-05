# © Copyright IBM Corporation 2018, 2026.
# LICENSE: GPL v3 license, Version 3 (http://www.gnu.org/licenses)

########## Dockerfile for Neo4j version 5.26.20 ##################################
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

FROM redhat/ubi9-minimal:latest as builder
ARG NEO4J_VER=5.26.20

ENV SOURCE_ROOT=/tmp
ENV MAVEN_OPTS="-Xmx2048m -Xss8m"

COPY neo4j.patch $SOURCE_ROOT/neo4j.patch

RUN microdnf  install -y java-17-openjdk java-17-openjdk-devel git wget tar which \
  && cd $SOURCE_ROOT \
  && JAVA_HOME="$(dirname $(dirname $(readlink -f $(which java))))" \
  && export PATH="$JAVA_HOME/bin:$SOURCE_ROOT/apache-maven-3.9.12/bin:$PATH" \
  && wget -q https://archive.apache.org/dist/maven/maven-3/3.9.12/binaries/apache-maven-3.9.12-bin.tar.gz \
  && tar -zxf apache-maven-3.9.12-bin.tar.gz \
  && git clone --depth 1 -b 5.26.20  https://github.com/neo4j/neo4j.git \
  && cd neo4j \
  && git apply $SOURCE_ROOT/neo4j.patch \
  && mvn spotless:apply -B -V \
  && mvn clean install -B -V -DskipTests

RUN tar zxf /tmp/neo4j/packaging/standalone/target/neo4j-community-5.26.20-SNAPSHOT-unix.tar.gz -C /tmp

#base image
FROM redhat/ubi9-minimal:latest

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# gather pre-requisite packages
RUN set -eux; \
    microdnf install -y --nodocs \
        findutils \
        gcc \
        git \
        gzip \
        hostname \
        java-17-openjdk-headless \
        jq \
        make \
        procps \
        shadow-utils \
        tar \
        wget \
        which; \
    \
    wget https://github.com/krallin/tini/releases/download/v0.19.0/tini-s390x; \
    cp tini-s390x /usr/bin/tini; \
    chmod +x /usr/bin/tini; \
    \
    git clone https://github.com/ncopa/su-exec.git; \
    cd su-exec; \
    git checkout 4c3bb42b093f14da70d8ab924b487ccfbb1397af; \
    echo d6c40440609a23483f12eb6295b5191e94baf08298a856bab6e15b10c3b82891 su-exec.c | sha256sum -c; \
    echo 2a87af245eb125aca9305a0b1025525ac80825590800f047419dc57bba36b334 Makefile | sha256sum -c; \
    make; \
    mv su-exec /usr/bin/su-exec; \
    chmod +x /usr/bin/su-exec; \
    rm -rf /tini /su-exec; \
    microdnf remove -y git* perl* make gcc glibc-headers glibc-devel libxcrypt-devel; \
    microdnf clean all
ENV PATH="${JAVA_HOME}/bin:${PATH}" \
    NEO4J_EDITION=community \
    NEO4J_HOME="/var/lib/neo4j" \
    LANG=C.UTF-8
ARG NEO4J_VER=5.26.20

COPY --from=builder /tmp/neo4j-community-5.26.20-SNAPSHOT /var/lib/neo4j-community-"5.26.20"

RUN set -eux; \
    groupadd --gid 7474 --system neo4j && useradd --uid 7474 --system --no-create-home --home "${NEO4J_HOME}" --gid neo4j neo4j; \
    mv /var/lib/neo4j-* "${NEO4J_HOME}"; \
    sed -i 's/Package Type:.*/Package Type: docker ubi9/' $NEO4J_HOME/packaging_info; \
     mkdir -p /startup; \
     wget https://raw.githubusercontent.com/neo4j/docker-neo4j-publish/master/"${NEO4J_VER}"/ubi9/community/local-package/docker-entrypoint.sh -P /startup; \
     wget https://raw.githubusercontent.com/neo4j/docker-neo4j-publish/master/"${NEO4J_VER}"/ubi9/community/local-package/neo4j-admin-report.sh -P /startup; \
     wget https://raw.githubusercontent.com/neo4j/docker-neo4j-publish/master/"${NEO4J_VER}"/ubi9/community/local-package/neo4j-plugins.json -P /startup; \
     wget https://raw.githubusercontent.com/neo4j/docker-neo4j-publish/master/"${NEO4J_VER}"/ubi9/community/local-package/utilities.sh -P /startup; \
     wget https://raw.githubusercontent.com/neo4j/docker-neo4j-publish/master/"${NEO4J_VER}"/ubi9/community/local-package/semver.jq -P /startup; \
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