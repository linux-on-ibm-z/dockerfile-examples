####################### Dockerfile for PhantomJS version 2.1.1 #################################
#
# PhantomJS is a headless WebKit scriptable with a JavaScript API. It has fast and native support for various web standards: DOM handling, CSS selector, JSON, Canvas, and SVG.
#
# To build PhantomJS image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# To use PhantomJS image, use following command:
# docker run --name <container_name> -v <phantomjs_file_path_in_host>:<phantomjs_file_path_in_container> -it <img_name> phantomjs <phantomjs_test_file_path_in_container>
# For example : docker run --name <container_name> -v /home/test.js:/home/test.js -it <image_name> phantomjs /home/test.js
#
################# Example of file: test.js ###################
#"use strict";
#console.log("Hello World!!");
#phantom.exit();
#################################################################################################
# This Dockerfile is no longer maintained. For the list of maintained Build Instructions and Dockerfiles,
# please refer to https://www.ibm.com/community/z/open-source-software/

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV QT_QPA_PLATFORM=offscreen

# Install the v2.1.1 available in Ubuntu repository
RUN apt-get update && apt-get install -y phantomjs \

# Clean up cache data and remove dependencies that are not required
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["phantomjs"]
