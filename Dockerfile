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

FROM alpine:3.6
LABEL Name=OAE-hilary-dependencies
LABEL Author=ApereoFoundation 
LABEL Email=oae@apereo.org

#
# Install node first according to official image on
# https://github.com/nodejs/docker-node/blob/bf84a38aeacb4f6aad34e07c79fd3a0084da5cd2/6/alpine/Dockerfile 
#
ENV NODE_VERSION 6.12.0

RUN addgroup -g 1000 node \
	&& adduser -u 1000 -G node -s /bin/sh -D node \
	&& apk add --no-cache \
	libstdc++ \
	&& apk add --no-cache --virtual .build-deps \
	binutils-gold \
	curl \
	g++ \
	gcc \
	gnupg \
	libgcc \
	linux-headers \
	make \
	python \
	&& for key in \
	94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
	FD3A5288F042B6850C66B31F09FE44734EB7990E \
	71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
	DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
	C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
	B9AE9905FFD7803F25714661B63B535A4C206CA9 \
	56730D5401028683275BD23C23EFEFE93C4CFFFE \
	77984A986EBC2AA786BC0F66B01FBB92821C587A \
	; do \
	gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
	gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ; \
	done \
	&& curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
	&& curl -SLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
	&& gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
	&& grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
	&& tar -xf "node-v$NODE_VERSION.tar.xz" \
	&& cd "node-v$NODE_VERSION" \
	&& ./configure \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& apk del .build-deps \
	&& cd .. \
	&& rm -Rf "node-v$NODE_VERSION" \
	&& rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt

ENV YARN_VERSION 1.3.2

RUN apk add --no-cache --virtual .build-deps-yarn curl gnupg tar \
	&& for key in \
	6A010C5166006599AA17F08146C2130DFD2497F5 \
	; do \
	gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
	gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ; \
	done \
	&& curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
	&& curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
	&& gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
	&& mkdir -p /opt/yarn \
	&& tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/yarn --strip-components=1 \
	&& ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
	&& ln -s /opt/yarn/bin/yarn /usr/local/bin/yarnpkg \
	&& rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
	&& apk del .build-deps-yarn

# 
# Install pdf2htmlex based on
# https://hub.docker.com/r/bwits/pdf2htmlex-alpine/
#
RUN apk --update add git ghostscript alpine-sdk xz poppler-dev pango-dev m4 libtool perl autoconf automake coreutils python-dev zlib-dev freetype-dev glib-dev cmake libxml2 libxml2-dev libxml2-utils && \
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
	graphicsmagick \
  && rm -rf /var/lib/apt/lists/*

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
