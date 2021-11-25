FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y debootstrap kpartx

COPY build-image.sh /build-image.sh
RUN chmod +x /build-image.sh