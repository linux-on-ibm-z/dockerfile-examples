# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############# Dockerfile for Apache Maven version 3.6.2 #######################################################################################
#
# Apache Maven is a software project management and comprehension tool. Based on the concept of a project object model (POM), Maven can managea project's build, reporting and documentation from a central piece of information.
#
# To build this image, from the directory containing this Dockerfile.
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start a container of Maven image, use following command:
# docker run --name <container_name> -it <image_name> /bin/bash
#
# To use Maven image from command line, use following command:
# docker run -it --name <container_name> -v <path_to_project_on_host>:/usr/src/mymaven -w /usr/src/mymaven <image_name> <maven_command>
# For ex. docker run -it --name maven_test -v /home/test/mvn/gs-maven/initial:/usr/src/mymaven -w /usr/src/mymaven  maven:s390x mvn clean install
#
##############################################################################################################################################

FROM s390x/ubuntu:16.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ARG MAVEN_VERSION=3.6.2
ARG USER_HOME_DIR="/root"
ARG SHA=d941423d115cd021514bfd06c453658b1b3e39e6240969caf4315ab7119a77299713f14b620fb2571a264f8dff2473d8af3cb47b05acf0036fc2553199a5c1ee
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN apt-get update && apt-get install -y \
    curl \
    tar \
    openjdk-8-jdk \
  && mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

COPY mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh

RUN chmod +x /usr/local/bin/mvn-entrypoint.sh

COPY settings-docker.xml /usr/share/maven/ref/

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]
