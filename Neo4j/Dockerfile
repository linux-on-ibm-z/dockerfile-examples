# © Copyright IBM Corporation 2018, 2020.
# LICENSE: GPL v3 license, Version 3 (http://www.gnu.org/licenses)

########## Dockerfile for Neo4j version 4.0.2 ##################################
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
# To simply run the resultant image, and provide a bash shell:
# docker run -it <image_name> /bin/bash
# 
# Use the following command to start neo4j server :
# docker run --name <container_name> -d -p <host-port>:<container-port> <image-name>
#
# Provide custom configuration file
# docker run --name <container_name> -d -p <host-port>:<container-port> -v /<path_on_host>/neo4j.conf:/root/neo4j/conf/neo4j.conf <image-name> 
#  
# Official website: https://neo4j.com/
#
##################################################################################

#Base Image
FROM s390x/ubuntu:18.04

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ARG NEO4J_VER=4.0.2
ENV NEO4J_EDITION=community
ENV NEO4J_HOME=/var/lib/neo4j
ENV NEO4J_TARBALL=neo4j-community-${NEO4J_VER}-unix.tar.gz
ENV JAVA_HOME=/usr/local/jdk-11.0.6+10
ENV JDK_TARBALL=OpenJDK11U-jdk_s390x_linux_openj9_11.0.6_10_openj9-0.18.1.tar.gz
ENV TINI_VERSION="v0.18.0"

RUN addgroup --system neo4j && adduser --system --no-create-home --home "${NEO4J_HOME}" --ingroup neo4j neo4j

COPY neo4jlabs-plugins.json /tmp/neo4jlabs-plugins.json
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Install dependencies
RUN  apt-get update  \
  && apt-get install -y  \
                tar \
                wget \
                curl \
                gosu \
                jq \
# Download adoptopenjdk
  && wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.6%2B10_openj9-0.18.1/${JDK_TARBALL} \
  && tar -zxf ${JDK_TARBALL} --directory /usr/local\
# Download tini
  && curl -L --fail --silent --show-error "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-s390x" > /sbin/tini \
  && chmod +x /sbin/tini \
# Download and unzip Neo4j pre build Binary
  && curl --fail --silent --show-error --location --remote-name https://dist.neo4j.org/${NEO4J_TARBALL} \
  && tar -xf ${NEO4J_TARBALL} --directory /var/lib \
  && mv /var/lib/neo4j-* "${NEO4J_HOME}" \
  && mv "${NEO4J_HOME}"/data /data \
  && mv "${NEO4J_HOME}"/logs /logs \
  && chown -R neo4j:neo4j /data \
  && chmod -R 777 /data \
  && chown -R neo4j:neo4j /logs \
  && chmod -R 777 /logs \
  && chown -R neo4j:neo4j "${NEO4J_HOME}" \
  && chmod -R 777 "${NEO4J_HOME}" \
  && ln -s /data "${NEO4J_HOME}"/data \
  && ln -s /logs "${NEO4J_HOME}"/logs \
  && chmod +x /docker-entrypoint.sh \
  && mv /tmp/neo4jlabs-plugins.json /neo4jlabs-plugins.json \
  && rm -rf /tmp/* \
# Clean up the unwanted packages and clear the source directory
  && apt-get remove -y \
                wget  \
                curl  \
  && apt-get autoremove -y \
  && apt autoremove -y \
  && apt-get clean \
  && rm -rf /${JDK_TARBALL} /${NEO4J_TARBALL} /var/lib/apt/lists/*

ENV PATH "${NEO4J_HOME}"/bin:"$JAVA_HOME"/bin:$PATH

WORKDIR "${NEO4J_HOME}"
  
# Define mount for backup of logs, data, conf & lib
VOLUME ["$NEO4J_HOME/logs","$NEO4J_HOME/data","$NEO4J_HOME/conf","$NEO4J_HOME/lib"]

# Port for Neo4j
EXPOSE 7474 7473 7687 6362 5000 6000 7000 5001 6001 2003 3637 1337

# Set the Entrypoint
ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
CMD ["neo4j"]

# End of Dockerfile
