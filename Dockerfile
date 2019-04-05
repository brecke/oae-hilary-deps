#
# Copyright 2018 Apereo Foundation (AF) Licensed under the
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

FROM node:10-alpine
LABEL Name=OAE-hilary-dependencies
LABEL Author=ApereoFoundation
LABEL Email=oae@apereo.org

# Installs latest Chromium (72) package.
RUN apk update && apk upgrade && \
    echo @edge http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
    echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories && \
    apk add --no-cache \
      chromium@edge \
      nss@edge \
      freetype@edge \
      harfbuzz@edge \
      ttf-freefont@edge

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Other dependencies
RUN apk --update --no-cache add \
		alpine-sdk \
    git \
		xz \
		m4 \
		libtool \
		autoconf \
		automake \
		coreutils \
		cmake \
		libpng \
		python \
		glib \
		libintl \
		libxml2 \
		libltdl \
		cairo \
		pango \
    ghostscript \
    graphicsmagick

# Dependencies for nodegit
RUN apk --update --no-cache add build-base libgit2-dev
RUN ln -s /usr/lib/libcurl.so.4 /usr/lib/libcurl-gnutls.so.4

# Install libreoffice
RUN apk add --no-cache libreoffice openjdk8-jre

