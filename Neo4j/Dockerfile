# © Copyright IBM Corporation 2018, 2024.
# LICENSE: GPL v3 license, Version 3 (http://www.gnu.org/licenses)

########## Dockerfile for Neo4j version 5.24.0 ##################################
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

FROM ubuntu:20.04 AS builder
ARG NEO4J_VER=5.24.0

ENV SOURCE_ROOT=/tmp
ENV MAVEN_OPTS="-Xmx2048m -Xss8m"
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-s390x
ENV PATH=$JAVA_HOME/bin:$SOURCE_ROOT/apache-maven-3.9.8/bin:$PATH

COPY neo4j-$NEO4J_VER.patch $SOURCE_ROOT/neo4j-$NEO4J_VER.patch

RUN apt update \
  && DEBIAN_FRONTEND=noninteractive apt install -y openjdk-17-jdk git wget tar \
  && cd $SOURCE_ROOT \
  && wget -q https://archive.apache.org/dist/maven/maven-3/3.9.8/binaries/apache-maven-3.9.8-bin.tar.gz \
  && tar -zxf apache-maven-3.9.8-bin.tar.gz \
  && git clone --depth 1 -b $NEO4J_VER https://github.com/neo4j/neo4j.git \
  && cd neo4j \
  && git apply $SOURCE_ROOT/neo4j-$NEO4J_VER.patch \
  && mvn clean install -B -V -DskipTests

RUN tar zxf /tmp/neo4j/packaging/standalone/target/neo4j-community-$NEO4J_VER-unix.tar.gz -C /tmp

#Base Image
FROM debian:bookworm-slim

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV JAVA_HOME=/opt/java/openjdk
COPY --from=eclipse-temurin:17 $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}" \
    NEO4J_EDITION=community \
    NEO4J_HOME="/var/lib/neo4j"
ARG NEO4J_VER=5.24.0

RUN addgroup --gid 7474 --system neo4j && adduser --uid 7474 --system --no-create-home --home "${NEO4J_HOME}" --ingroup neo4j neo4j

COPY --from=builder /tmp/neo4j-community-5.24.0 /var/lib/neo4j-community-5.24.0

RUN apt update \
    && apt-get install -y curl gcc git jq make procps tini wget \
    && mv /var/lib/neo4j-* "${NEO4J_HOME}" \
    && wget https://repo1.maven.org/maven2/org/neo4j/client/neo4j-browser/5.15.0/neo4j-browser-5.15.0.jar -P "${NEO4J_HOME}"/lib \
    && wget https://repo1.maven.org/maven2/org/neo4j/procedure/apoc-core/5.24.0/apoc-core-5.24.0-core.jar -P "${NEO4J_HOME}"/labs \
    && sed -i 's/Package Type:.*/Package Type: docker bullseye/' $NEO4J_HOME/packaging_info \
    && mkdir -p /startup \
    && wget https://raw.githubusercontent.com/neo4j/docker-neo4j-publish/master/5.24.0/bullseye/community/local-package/docker-entrypoint.sh -P /startup \
    && wget https://raw.githubusercontent.com/neo4j/docker-neo4j-publish/master/5.24.0/bullseye/community/local-package/neo4j-admin-report.sh -P /startup \
    && wget https://raw.githubusercontent.com/neo4j/docker-neo4j-publish/master/5.24.0/bullseye/community/local-package/neo4j-plugins.json -P /startup \
    && wget https://raw.githubusercontent.com/neo4j/docker-neo4j-publish/master/5.24.0/bullseye/community/local-package/utilities.sh -P /startup \
    && wget https://raw.githubusercontent.com/neo4j/docker-neo4j-publish/master/5.24.0/bullseye/community/local-package/semver.jq -P /startup \
    && chmod +x /startup/neo4j-admin-report.sh /startup/docker-entrypoint.sh /startup/utilities.sh /startup/semver.jq \
    && mv /startup/neo4j-admin-report.sh "${NEO4J_HOME}"/bin/neo4j-admin-report \
    && mv "${NEO4J_HOME}"/data /data \
    && mv "${NEO4J_HOME}"/logs /logs \
    && chown -R neo4j:neo4j /data \
    && chmod -R 777 /data \
    && chown -R neo4j:neo4j /logs \
    && chmod -R 777 /logs \
    && chown -R neo4j:neo4j "${NEO4J_HOME}" \
    && chmod -R 777 "${NEO4J_HOME}" \
    && chmod -R 755 "${NEO4J_HOME}/bin" \
    && ln -s /data "${NEO4J_HOME}"/data \
    && ln -s /logs "${NEO4J_HOME}"/logs \
    && git clone https://github.com/ncopa/su-exec.git \
    && cd su-exec \
    && git checkout 4c3bb42b093f14da70d8ab924b487ccfbb1397af \
    && echo d6c40440609a23483f12eb6295b5191e94baf08298a856bab6e15b10c3b82891 su-exec.c | sha256sum -c \
    && echo 2a87af245eb125aca9305a0b1025525ac80825590800f047419dc57bba36b334 Makefile | sha256sum -c \
    && make \
    && mv /su-exec/su-exec /usr/bin/su-exec \
    && apt-get -y purge --auto-remove curl gcc git make \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /su-exec


ENV PATH "${NEO4J_HOME}"/bin:$PATH

WORKDIR "${NEO4J_HOME}"

VOLUME /data /logs

EXPOSE 7474 7473 7687

ENTRYPOINT ["tini", "-g", "--", "/startup/docker-entrypoint.sh"]
CMD ["neo4j"]

# End of Dockerfile
