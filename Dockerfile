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

ENV REFRESHED_/AT 20181123
ENV HOME_PATH "/"
ENV FONTFORGE_SOURCE "https://github.com/fontforge/fontforge.git"

# Dependencies for pdf2htmlEX and poppler
RUN apk --update --no-cache add \
		alpine-sdk \
		xz \
		pango-dev \
		m4 \
		libtool \
		perl \
		autoconf \
		automake \
		coreutils \
		python-dev \
		zlib-dev \
		freetype-dev \
		glib-dev \
		cmake \
		libxml2-dev \
		libpng \
		libjpeg-turbo-dev \
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

# Install fontforge libuninameslist
RUN echo "Installing fontforge libuninameslist ..." \
    && cd "$HOME_PATH" \
		&& git clone https://github.com/fontforge/libuninameslist.git \
    && cd libuninameslist \
		&& autoreconf -i \
		&& automake \
		&& ./configure \
		&& make \
		&& make install

# Install fontforge
RUN echo "Installing fontforge ..." \
    && cd "$HOME_PATH" \
	 	&& git clone --depth 1 --single-branch --branch 20170731 "$FONTFORGE_SOURCE" \
		&& cd fontforge/ \
		&& git checkout tags/20170731 \
		&& ./bootstrap \
		&& ./configure \
		&& make \
		&& make install


# Cleaning up
RUN echo "Removing sources ..." \
	  && cd "$HOME_PATH" && rm -rf "libuninameslist" \
	  && cd "$HOME_PATH" && rm -rf "fontforge" 

# Install libreoffice
RUN apk add --no-cache libreoffice openjdk8-jre

