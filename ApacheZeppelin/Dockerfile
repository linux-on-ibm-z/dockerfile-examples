# © Copyright IBM Corporation 2017, 2024.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############## Dockerfile for Apache Zeppelin version 0.11.2 ###############
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
# http://zeppelin.apache.org/docs/0.11.1/index.html
#
#################################################################################

# Base Image
FROM s390x/ubuntu:22.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV Z_VERSION=0.11.2

ENV LOG_TAG="[ZEPPELIN_${Z_VERSION}]:" \
    Z_HOME="/zeppelin" \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x \
    PATH=$JAVA_HOME/bin:$PATH \
    ZEPPELIN_ADDR="0.0.0.0"

RUN echo "$LOG_TAG update and install basic packages" && \
    apt-get -y update && \
    apt-get install -y locales && \
    locale-gen $LANG && \
    apt-get install -y software-properties-common && \
    apt-get -y autoclean && \
    apt-get -y dist-upgrade && \
    apt-get install -y build-essential wget && \
    echo "$LOG_TAG install tini related packages" && \
    apt-get install -y apt-transport-https && \
    wget -O tini-s390x https://github.com/krallin/tini/releases/download/v0.19.0/tini-s390x && \
    mv tini-s390x /usr/bin/tini && \
    chmod +x /usr/bin/tini && \
    echo "$LOG_TAG Install java8" && \
    apt-get -y update && \
    apt-get install -y openjdk-11-jdk && \
    apt-get -y update && DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata && \
    # Note: intake-parquet and apache_beam python packages are not included on s390x
    echo "$LOG_TAG Install python related packages" && \
    apt-add-repository universe && \
    apt-get -y update && \
    apt-get install -y python3 python3-dev python3-pip python-is-python3 && \
    apt-get install -y bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 libssl-dev \
    git mercurial subversion cmake && \
    apt-get install -y gfortran && \
    # numerical/algebra packages
    apt-get install -y libblas-dev libatlas-base-dev  liblapack-dev libopenblas-dev && \
    # font, image
    apt-get install -y libpng-dev libfreetype6-dev libxft-dev libjpeg-dev && \
    python -m pip install --upgrade pip && \
    # for tkinter
    apt-get install -y python3-tk libxml2-dev libxslt-dev zlib1g-dev && \
    apt-get install -y python3-ipykernel && \
    apt-get install -y libzmq3-dev libcurl4-openssl-dev libssl-dev jupyter-core jupyter-client && \
    hash -r && \
    echo "$LOG_TAG Install python modules. This may take some time." && \
    python -m pip install -q pycodestyle && \
    #downgraded cython because of decpricated conditional compilation. Version should be changes to latest after grpcio community fix it.
    python -m pip install -q Cython==0.29.33 && \
    python -m pip install -q setuptools==59.5.0 && \
    GRPC_PYTHON_BUILD_WITH_CYTHON=1 GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1 python -m pip install -q grpcio && \
    python -m pip install setuptools==68.2.2 && \
    python -m pip install -q pybind11 && \
    python -m pip install -q 'numpy==1.*' && \
    python -m pip install -q 'pandas==1.3.*' && \
    python -m pip install -q 'scipy==1.*' && \
    python -m pip install -q bkzep==0.6.1 && \
    python -m pip install -q hvplot && \
    python -m pip install -q 'protobuf==3.*' && \
    python -m pip install -q pandasql==0.7.3 && \
    python -m pip install -q 'ipython==7.*' && \
    python -m pip install -q 'ipykernel==5.*' && \
    python -m pip install -q 'jupyter_client==5.*' && \
    python -m pip install -q 'bokeh==3.2.0' && \
    python -m pip install -q panel && \
    python -m pip install -q holoviews && \
    python -m pip install -q 'pyyaml==5.3.*' && \
    python -m pip install -q seaborn && \
    python -m pip install -q plotnine==0.8.0 && \
    python -m pip install -q intake && \
    python -m pip install -q altair && \
    # for matplotlib
    python -m pip install -q matplotlib==3.5.1 && \
    echo "$LOG_TAG Install R related packages" && \
    apt-get -y --allow-unauthenticated install r-base r-base-dev libzmq3-dev libgit2-dev r-cran-devtools && \
    R -e "install.packages('evaluate', repos = 'https://cloud.r-project.org')" && \
    R -e "install.packages('knitr', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('ggplot2', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('googleVis', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('data.table', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('IRkernel', repos = 'https://cloud.r-project.org');IRkernel::installspec(user = FALSE)" && \
    R -e "install.packages('shiny', repos = 'https://cloud.r-project.org')" && \
    echo "$LOG_TAG Install R related packages2" && \
    R -e "install.packages('Rcpp', repos='http://cran.us.r-project.org')" && \
    Rscript -e "library('devtools'); library('Rcpp'); install_github('ramnathv/rCharts')" && \
    echo "$LOG_TAG Cleanup" && \
    apt-get -y autoclean && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "$LOG_TAG Download Zeppelin binary" && \
    wget --quiet -O /tmp/zeppelin-${Z_VERSION}-bin-all.tgz "https://dlcdn.apache.org/zeppelin/zeppelin-${Z_VERSION}/zeppelin-${Z_VERSION}-bin-all.tgz" && \
    tar -zxvf /tmp/zeppelin-${Z_VERSION}-bin-all.tgz && \
    rm -rf /tmp/zeppelin-${Z_VERSION}-bin-all.tgz && \
    mkdir -p ${Z_HOME} && \
    mv /zeppelin-${Z_VERSION}-bin-all/* ${Z_HOME}/ && \
    chown -R root:root ${Z_HOME} && \
    mkdir -p ${Z_HOME}/logs ${Z_HOME}/run ${Z_HOME}/webapps && \
    # Allow process to edit /etc/passwd, to create a user entry for zeppelin
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd && \
    # Give access to some specific folders
    chmod -R 775 "${Z_HOME}/logs" "${Z_HOME}/run" "${Z_HOME}/notebook" "${Z_HOME}/conf" && \
    # Allow process to create new folders (e.g. webapps)
    chmod 775 ${Z_HOME}

COPY log4j.properties ${Z_HOME}/conf/
COPY log4j_docker.properties ${Z_HOME}/conf/

USER 1000

EXPOSE 8080

ENTRYPOINT [ "/usr/bin/tini", "--" ]
WORKDIR ${Z_HOME}
CMD ["bin/zeppelin.sh"]
