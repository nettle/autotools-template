# Use ubuntu 18.04, 16.04 or 14.04
FROM ubuntu:18.04

# Prepare update
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qqy update
RUN apt-get -qqy install --no-install-recommends apt-utils

# Install required packages
RUN apt-get -qqy install build-essential autoconf automake libtool gcc g++

# Setting work dir
WORKDIR /app
# Copy all files
COPY . /app

# Make all and run tests
RUN make rebuild
RUN make run-tests
