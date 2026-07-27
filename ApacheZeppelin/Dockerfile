# © Copyright IBM Corporation 2017, 2026.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############## Dockerfile for Apache Zeppelin version 0.12.1 ###############
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
# http://zeppelin.apache.org/docs/0.12.1/index.html
#
#################################################################################

# Base image
FROM s390x/ubuntu:22.04

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV Z_VERSION="0.12.1"

ENV LOG_TAG="[ZEPPELIN_${Z_VERSION}]:" \
    ZEPPELIN_HOME="/opt/zeppelin" \
    HOME="/opt/zeppelin" \
    LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME="/usr/lib/jvm/java-11-openjdk-s390x" \
    ZEPPELIN_ADDR="0.0.0.0"

# Miniconda installer available for Linux s390x.
ARG MINICONDA_VERSION="py312_25.1.1-2"
ARG MINICONDA_SHA256="55c681937c27e13a8ed818d1fec182e623e0308fffc1b10605896dac15f90077"

RUN echo "$LOG_TAG update and install basic packages" && \
    apt-get -y update && \
    apt-get install -y locales language-pack-en && \
    locale-gen $LANG && \
    apt-get -y autoclean && \
    apt-get -y dist-upgrade && \
    echo "$LOG_TAG Install java 11" && \
    apt-get install -y ca-certificates tini openjdk-11-jdk wget unzip && \
    echo "$LOG_TAG Install build tools" && \
    apt-get install -y build-essential cmake git bzip2 gfortran pkg-config && \
    echo "$LOG_TAG Install library dependencies" && \
    apt-get install -y \
    libglib2.0-0 libxext6 libsm6 libxrender1 libssl-dev \
    libffi-dev libxml2-dev libxslt-dev zlib1g-dev && \
    # numerical/algebra packages
    apt-get install -y libblas-dev liblapack-dev libopenblas-dev && \
    # font, image
    apt-get install -y libpng-dev libfreetype6-dev libfontconfig1-dev libxft-dev libjpeg-dev && \
    # hdf5, netcdf, zmq, curl
    apt-get install -y libhdf5-dev libnetcdf-dev libzmq3-dev libcurl4-openssl-dev && \
    echo "$LOG_TAG Install R related packages" && \
    apt-get -y install r-base r-base-dev r-cran-remotes && \
    echo "$LOG_TAG Cleanup" && \
    apt-get -y autoclean && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Python package environment.
#
# R is installed using Ubuntu/CRAN instead of conda because the upstream
# conda-forge R environment is not available for Linux s390x.
COPY env_python_3_with_R_s390x.yml /env_python_3_with_R_s390x.yml

RUN set -ex && \
    echo "$LOG_TAG Install Miniconda for s390x" && \
    wget -nv -O /tmp/miniconda.sh "https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-s390x.sh" && \
    echo "${MINICONDA_SHA256} /tmp/miniconda.sh" > /tmp/anaconda.sha256 && \
    sha256sum --strict -c /tmp/anaconda.sha256 && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm -v /tmp/miniconda.sh /tmp/anaconda.sha256 && \
    export PATH=/opt/conda/bin:$PATH && \
    conda config --set always_yes yes --set changeps1 no && \
    conda info -a && \
    echo "$LOG_TAG Create Zeppelin Python environment" && \
    conda env update -f /env_python_3_with_R_s390x.yml --prune && \
    echo "$LOG_TAG Install grpcio using the required s390x build settings" && \
    /opt/conda/envs/python_3_with_R/bin/python -m pip install -q \
        "Cython==0.29.33" \
        "setuptools==59.5.0" && \
    GRPC_PYTHON_BUILD_WITH_CYTHON=1 \
    GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1 \
    /opt/conda/envs/python_3_with_R/bin/python -m pip install -q \
        --no-build-isolation \
        "grpcio==1.75.0" && \
    /opt/conda/envs/python_3_with_R/bin/python -m pip install -q \
        "setuptools==68.2.2" wheel && \
    # Cleanup
    rm -rf /root/.cache /root/.conda /opt/conda/pkgs/* && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    conda clean -ay

ENV PATH="/opt/conda/envs/python_3_with_R/bin:/opt/conda/bin:${JAVA_HOME}/bin:${PATH}"

RUN echo "$LOG_TAG Install R related packages" && \
    R -e "install.packages('evaluate',  repos='https://cloud.r-project.org')" && \
    R -e "install.packages('base64enc', repos='https://cloud.r-project.org')" && \
    R -e "install.packages('knitr',     repos='https://cloud.r-project.org')" && \
    R -e "install.packages('ggplot2',   repos='https://cloud.r-project.org')" && \
    R -e "install.packages('googleVis', repos='https://cloud.r-project.org')" && \
    R -e "install.packages('data.table',repos='https://cloud.r-project.org')" && \
    R -e "install.packages('IRkernel',  repos='https://cloud.r-project.org')" && \
    R -e "IRkernel::installspec(user = FALSE)" && \
    R -e "install.packages('shiny',     repos='https://cloud.r-project.org')" && \
    echo "$LOG_TAG Cleanup" && \
    rm -rf /root/.cache /root/.Rhistory /tmp/* /var/tmp/*

RUN echo "$LOG_TAG Download Zeppelin binary" && \
    mkdir -p ${ZEPPELIN_HOME} && \
    wget --quiet -O /tmp/zeppelin-${Z_VERSION}-bin-all.tgz "https://www.apache.org/dyn/closer.lua/zeppelin/zeppelin-${Z_VERSION}/zeppelin-${Z_VERSION}-bin-all.tgz?action=download" && \
    tar --strip-components=1 -zxvf /tmp/zeppelin-${Z_VERSION}-bin-all.tgz -C ${ZEPPELIN_HOME} && \
    rm -rf /tmp/zeppelin-${Z_VERSION}-bin-all.tgz && \
    chown -R root:root ${ZEPPELIN_HOME} && \
    mkdir -p ${ZEPPELIN_HOME}/logs ${ZEPPELIN_HOME}/run ${ZEPPELIN_HOME}/webapps && \
    # Allow process to edit /etc/passwd, to create a user entry for zeppelin
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd && \
    # Give access to some specific folders
    chmod -R 775 "${ZEPPELIN_HOME}/logs" "${ZEPPELIN_HOME}/run" "${ZEPPELIN_HOME}/notebook" "${ZEPPELIN_HOME}/conf" && \
    # Allow process to create new folders (e.g. webapps)
    chmod 775 ${ZEPPELIN_HOME} && \
    chmod -R 775 /opt/conda && \
    # Pre-create jupyter and R user dirs so UID 1000 can write to them at runtime
    mkdir -p "${ZEPPELIN_HOME}/.local/share/jupyter" \
             "${ZEPPELIN_HOME}/.ipython" \
             "${ZEPPELIN_HOME}/.config/matplotlib" && \
    chmod -R 775 "${ZEPPELIN_HOME}/.local" "${ZEPPELIN_HOME}/.ipython" "${ZEPPELIN_HOME}/.config"

COPY log4j.properties "${ZEPPELIN_HOME}/conf/"
COPY log4j_docker.properties "${ZEPPELIN_HOME}/conf/"
COPY log4j2.properties "${ZEPPELIN_HOME}/conf/"
COPY log4j2_docker.properties "${ZEPPELIN_HOME}/conf/"

USER 1000

EXPOSE 8080

ENTRYPOINT [ "/usr/bin/tini", "--" ]

WORKDIR ${ZEPPELIN_HOME}

CMD ["bin/zeppelin.sh"]
