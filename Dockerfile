#
# Copyright 2017 Apereo Foundation (AF) Licensed under the
# Educational Community License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may
# obtain a copy of the License at
#
#     http://opensource.org/licenses/ECL-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an "AS IS"
# BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing
# permissions and limitations under the License.
#

#
# Setup in two steps
#
# Step 1: Build the image
# $ docker build -f Dockerfile -t oae-hilary-deps:latest .
# Step 2: Run the docker
# $ docker run -it --name=hilary-deps --net=host oae-hilary-deps:latest
#

FROM node:6.12.0-alpine
LABEL Name=OAE-hilary-dependencies
LABEL Author=ApereoFoundation 
LABEL Email=oae@apereo.org

# 
# Install pdf2htmlex based on
# https://hub.docker.com/r/bwits/pdf2htmlex-alpine/
#
RUN apk --update add git alpine-sdk xz poppler-dev pango-dev m4 libtool perl autoconf automake coreutils python-dev zlib-dev freetype-dev glib-dev cmake libxml2 libxml2-dev libxml2-utils && \
	cd / && \
	git clone https://github.com/BWITS/fontforge.git && \
	cd fontforge && \
	./bootstrap --force && \
	./configure --without-iconv && \
	make && \
	make install && \
	cd / && \
	git clone git://github.com/coolwanglu/pdf2htmlEX.git && \
	cd pdf2htmlEX && \
	export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig && \
	cmake . && make && sudo make install && \
	apk del alpine-sdk xz poppler-dev pango-dev m4 libtool perl autoconf automake coreutils python-dev zlib-dev freetype-dev glib-dev cmake && \
	apk add libpng python freetype glib libintl libltdl cairo poppler pango && \
	rm -rf /var/lib/apt/lists/* && \
	rm /var/cache/apk/* && \
	rm -rf /fontforge /libspiro /libuninameslist /pdf2htmlEX

RUN apk add --no-cache \
  chrpath \ 
  poppler \
  poppler-utils \
  && rm -rf /var/lib/apt/lists/*
  # pdf2htmlex \
  # python-poppler \ 

#
# Install libreoffice based on
# https://github.com/ellerbrock/docker-collection/blob/master/dockerfiles/alpine-libreoffice/Dockerfile
# 
# Optional Configuration Parameter
ARG SERVICE_USER
ARG SERVICE_HOME
# Default Settings
ENV SERVICE_USER ${SERVICE_USER:-office}
ENV SERVICE_HOME ${SERVICE_HOME:-/home/${SERVICE_USER}}
ENV VERSION 0.0.1
RUN adduser -h ${SERVICE_HOME} -s /sbin/nologin -u 1001 -D ${SERVICE_USER} && \
	apk add --no-cache \
	openjdk8 \
	libreoffice \
	libreoffice-base \
	ttf-freefont
