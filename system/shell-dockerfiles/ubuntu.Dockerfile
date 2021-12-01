FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

RUN mkdir scripts
COPY packages /scripts/
COPY install.sh /scripts/install.sh
RUN cd /scripts && ./install.sh
