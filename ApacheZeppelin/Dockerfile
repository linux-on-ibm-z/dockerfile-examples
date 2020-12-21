# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############## Dockerfile for Apache Zeppelin version 0.8.2 ###############
#
# This Dockerfile builds a basic installation of Apache Zeppelin.
#
# Web-based notebook that enables data-driven,interactive data analytics and collaborative documents with SQL, Scala and more.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Apache Zeppelin run the below command:
# docker run --name <container_name> -p <host_port>:8080 -d <image_name>
#
# We can view the Apache Zeppelin UI at http://<zeppelin-host-ip>:<port_number>
#
# Reference:
# http://zeppelin.apache.org/docs/0.8.2/index.html
#
#################################################################################

# Base Image
FROM s390x/ubuntu:20.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG Z_VERSION=0.8.2

ENV LOG_TAG="[ZEPPELIN_${Z_VERSION}]:" \
        Z_HOME="/zeppelin" \
        LANG=en_US.UTF-8 \
        LC_ALL=en_US.UTF-8 \
        DEBIAN_FRONTEND=noninteractive \
        SOURCE_ROOT=/opt \
        JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x \
        PATH=$JAVA_HOME/bin:$PATH \
        ZEPPELIN_ADDR="0.0.0.0"

# Install dependencies
RUN apt-get update && apt-get -y install \
                curl \
                build-essential \
                jupyter \
                openjdk-8-jdk \
                openjdk-8-jdk-headless \
                phantomjs \
                tar \
                unzip \
                wget \
                python3-dev \
                python3-pip \
                gfortran \
                libblas-dev \
                liblapack-dev \
                libpng-dev \
                libjpeg-dev \
                libfreetype6-dev \
                libxft-dev \
                locales \
                python3-tk \
                libxml2-dev \
                libgit2-dev \
                libxslt1-dev \
                zlib1g-dev \
        &&      locale-gen $LANG \
        &&      pip3 install --upgrade pip \
        &&      pip3 install numpy matplotlib && \
    echo "$LOG_TAG Install R related packages" && \
    echo "PATH: $PATH" && \
    apt-get -y update && \
    apt-get -y --allow-unauthenticated install r-base r-base-dev && \
    R -e "install.packages('evaluate', repos = 'https://cloud.r-project.org')" && \
    R -e "install.packages('knitr', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('ggplot2', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('googleVis', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('data.table', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('IRkernel', repos = 'https://cloud.r-project.org');IRkernel::installspec()" && \
    R -e "install.packages('shiny', repos = 'https://cloud.r-project.org')" && \
    # for devtools, Rcpp
    apt-get -y install libcurl4-gnutls-dev libssl-dev && \
    R -e "install.packages('devtools', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('Rcpp', repos='http://cran.us.r-project.org')" && \
    Rscript -e "library('devtools'); library('Rcpp'); install_github('ramnathv/rCharts')" \
# Install tini and kubectl
    apt-get install -y apt-transport-https && \
    cd $SOURCE_ROOT && \
    wget https://github.com/krallin/tini/releases/download/v0.18.0/tini-s390x && mv $SOURCE_ROOT/tini-s390x /usr/bin/tini && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl && \
# Download Apache Zeppelin binaries
    echo "$LOG_TAG Download Zeppelin binary" && \
    mkdir -p ${Z_HOME} && \
    wget --quiet -O /tmp/zeppelin-${Z_VERSION}-bin-all.tgz https://mirrors.estointernet.in/apache/zeppelin/zeppelin-${Z_VERSION}/zeppelin-${Z_VERSION}-bin-all.tgz && \
    tar -zxvf /tmp/zeppelin-${Z_VERSION}-bin-all.tgz -C ${Z_HOME} --strip-components 1 && \
    rm -rf /tmp/zeppelin-${Z_VERSION}-bin-all.tgz && \
    chown -R root:root ${Z_HOME} && \
    mkdir -p ${Z_HOME}/logs ${Z_HOME}/run ${Z_HOME}/webapps && \
    # Allow process to edit /etc/passwd, to create a user entry for zeppelin
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd && \
    # Give access to some specific folders
    chmod -R 775 "${Z_HOME}/logs" "${Z_HOME}/run" "${Z_HOME}/notebook" "${Z_HOME}/conf" && \
    # Allow process to create new folders (e.g. webapps)
    chmod 775 ${Z_HOME} && \
# Clean up of unused packages and source directory.
   apt autoremove -y && \
   apt-get clean  && rm -rf /var/lib/apt/lists/*

# Expose default port
EXPOSE 8080

RUN chmod +x /usr/bin/tini

USER 1000

# Start Apache Zeppelin
ENTRYPOINT [ "/usr/bin/tini", "--" ]
WORKDIR ${Z_HOME}
CMD ["bin/zeppelin.sh"]
