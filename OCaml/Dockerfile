# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

##########  Dockerfile for OCaml 4.08.0 #####################
#
# OCaml is an industrial strength programming language supporting functional, 
# imperative and object-oriented styles.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run -it <image_name> /bin/bash
#
# Below is the command to use OCaml:
# docker run --name <container_name> -it <image_name> ocaml <argument>
#
# Example to execute test file using OCaml:
# docker run --rm --name <container_name> -v /home/test/ocaml_test.ml:/home/ocaml_test.ml -it <image_name> ocaml /home/ocaml_test.ml
#
############################ Sample ocaml_test.ml ####################################
#
# print_string "Hello world!\n";;
#
#######################################################################################
#
################################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

WORKDIR "/root"

#Installing oCaml
RUN apt-get update && apt-get install -y \
    gcc \
	git \
	make \    
# Download the OCaml source tarball from OCaml site
 && git clone -b 4.08.0 git://github.com/ocaml/ocaml.git \
 &&	cd ocaml \    
# Configure the system
 && ./configure \    
# Build the OCaml bytecode compiler
 && make world \    
# Build the native-code compiler, then use it to compile fast versions of the OCaml compilers:
 && make opt \
 && make opt.opt \    
# Install the OCaml system:
 && umask 022 \
 &&	make install \    
# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    gcc \
	git \
	make \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && rm -rf /root/ocaml

# Start OCaml
CMD ["ocaml"]
         
# End of Dockerfile
